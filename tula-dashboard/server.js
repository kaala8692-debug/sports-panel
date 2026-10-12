const express = require('express');
const path = require('path');
const fs = require('fs');
const app = express();
app.use(express.json());

const DB_FILE = path.join(__dirname, 'database.json');

// 🗄️ डेटाबेस लोड करने का फंक्शन (अब status: "ACTIVE" के साथ लोड होगा)
function loadDB() {
    if (!fs.existsSync(DB_FILE)) {
        const initialData = {
            username: "superadmin",
            role: "SUPER_ADMIN",
            totalSystemPoints: 1030000,
            masterAccounts: [
                { username: "Master777", password: "123", points: 58000, firstLogin: true, status: "ACTIVE", players: [{ username: "Player1", password: "123", points: 12000, firstLogin: true }] }
            ],
            logs: []
        };
        fs.writeFileSync(DB_FILE, JSON.stringify(initialData, null, 4));
        return initialData;
    }
    return JSON.parse(fs.readFileSync(DB_FILE, 'utf8'));
}

function saveDB(data) {
    fs.writeFileSync(DB_FILE, JSON.stringify(data, null, 4));
}

let adminAccount = loadDB();

// ⚡ रूट्स लोड कराना
app.get('/', (req, res) => res.sendFile(path.join(__dirname, 'index.html')));
app.get('/master-dashboard', (req, res) => res.sendFile(path.join(__dirname, 'master-dashboard.html')));
app.get('/player', (req, res) => res.sendFile(path.join(__dirname, 'player.html')));
app.get('/terms', (req, res) => res.sendFile(path.join(__dirname, 'terms.html')));

// 🔑 API: खुद के पॉइंट्स बढ़ाएं
app.post('/api/admin/add-points', (req, res) => {
    const { amount } = req.body;
    if(!amount || amount <= 0) return res.json({ success: false });
    adminAccount.totalSystemPoints += amount;
    saveDB(adminAccount);
    res.json({ success: true, newBalance: adminAccount.totalSystemPoints });
});

// 🔑 API: नया मास्टर बनाना (अब डिफॉल्ट रूप से ACTIVE स्टेटस के साथ बनेगा)
app.post('/api/admin/create-master', (req, res) => {
    const { username, points } = req.body;
    if (adminAccount.totalSystemPoints < points) return res.json({ success: false });
    adminAccount.totalSystemPoints -= points;
    adminAccount.masterAccounts.push({ 
        username: username, 
        password: "123", 
        points: points, 
        firstLogin: true, 
        status: "ACTIVE", // 🟢 शुरुआती स्टेटस चालू रहेगा
        players: [] 
    });
    saveDB(adminAccount);
    res.json({ success: true });
});

// 🔑 API: पुराना मास्टर रीचार्ज करना
app.post('/api/admin/recharge-master', (req, res) => {
    const { username, points } = req.body;
    let master = adminAccount.masterAccounts.find(m => m.username.toLowerCase() === username.toLowerCase());
    if (!master || adminAccount.totalSystemPoints < points) return res.json({ success: false });
    adminAccount.totalSystemPoints -= points;
    master.points += points;
    saveDB(adminAccount);
    res.json({ success: true });
});

// 🚫 👑 असली ब्रह्मास्त्र API: मास्टर को ब्लॉक या अनब्लॉक करने के लिए
app.post('/api/admin/toggle-master-status', (req, res) => {
    const { username } = req.body;
    let master = adminAccount.masterAccounts.find(m => m.username.toLowerCase() === username.toLowerCase());
    
    if (!master) return res.json({ success: false, message: "मास्टर नहीं मिला!" });
    
    // अगर ACTIVE है तो BLOCKED कर दो, और अगर BLOCKED है तो ACTIVE कर दो
    master.status = master.status === "ACTIVE" ? "BLOCKED" : "ACTIVE";
    saveDB(adminAccount);
    
    res.json({ success: true, newStatus: master.status });
});

// डेटा भेजने की मुख्य API (अगर मास्टर ब्लॉक है तो उसका डेटा रोकने के लिए सुरक्षा चक्र)
app.get('/api/admin/dashboard', (req, res) => {
    adminAccount = loadDB();
    res.json({ success: true, admin: adminAccount });
});

// 🎮 API: मास्टर के अंदर प्लेयर की आईडी बनाना
app.post('/api/master/create-player', (req, res) => {
    const { masterName, playerUser, points } = req.body;
    let master = adminAccount.masterAccounts.find(m => m.username.toLowerCase() === masterName.toLowerCase());
    
    // 🛡️ सुरक्षा चक्र: अगर मास्टर ब्लॉक है तो वह प्लेयर नहीं बना सकता
    if (!master || master.status === "BLOCKED") return res.json({ success: false, message: "आपका मास्टर अकाउंट सस्पेंड है!" });
    if (master.points < points) return res.json({ success: false, message: "पॉइंट्स कम हैं!" });
    
    master.points -= points;
    master.players.push({ username: playerUser, password: "123", points: points, firstLogin: true });
    saveDB(adminAccount);
    res.json({ success: true, newMasterBalance: master.points });
});

app.listen(3000, () => console.log("TULA111 ब्लॉक-एंटी-चीट इंजन के साथ लाइव है!"));
// ➕ मास्टर द्वारा नई प्लेयर आईडी बनाने का रूट
app.post('/api/master/create-player', (req, res) => {
    const { masterUsername, playerUsername, playerPassword, initialPoints } = req.body;
    let db = loadDB();

    const master = db.masterAccounts.find(m => m.username === masterUsername);
    if (!master) return res.json({ success: false, message: "मास्टर अकाउंट नहीं मिला!" });
    
    if (master.status === "BLOCKED") {
        return res.json({ success: false, message: "आपका मास्टर अकाउंट ब्लॉक है! आप प्लेयर नहीं बना सकते।" });
    }

    let playerExists = false;
    db.masterAccounts.forEach(m => {
        if (m.players && m.players.find(p => p.username === playerUsername)) {
            playerExists = true;
        }
    });
    if (playerExists) return res.json({ success: false, message: "यह प्लेयर यूजरनेम पहले से मौजूद है!" });

    const pointsToDeduct = parseFloat(initialPoints) || 0;
    if (master.points < pointsToDeduct) {
        return res.json({ success: false, message: "आपके पास पर्याप्त पॉइंट्स नहीं हैं!" });
    }

    master.points -= pointsToDeduct;
    if (!master.players) master.players = [];
    
    master.players.push({
        username: playerUsername,
        password: playerPassword || "123",
        points: pointsToDeduct,
        status: "ACTIVE"
    });

    saveDB(db);
    res.json({ success: true, message: `प्लेयर ${playerUsername} की आईडी सफलतापूर्वक बन गई है!`, newMasterBalance: master.points });
});

// ⚡ प्लेयर को दोबारा पॉइंट भेजने का रूट
app.post('/api/master/recharge-player', (req, res) => {
    const { masterUsername, playerUsername, points } = req.body;
    let db = loadDB();

    const master = db.masterAccounts.find(m => m.username === masterUsername);
    if (!master || master.status === "BLOCKED") return res.json({ success: false, message: "अनाधिकृत या ब्लॉक मास्टर!" });

    const pointsToTransfer = parseFloat(points) || 0;
    if (master.points < pointsToTransfer) return res.json({ success: false, message: "पॉइंट्स कम हैं!" });

    const player = master.players.find(p => p.username === playerUsername);
    if (!player) return res.json({ success: false, message: "प्लेयर नहीं मिला!" });

    master.points -= pointsToTransfer;
    player.points += pointsToTransfer;

    saveDB(db);
    res.json({ success: true, message: "प्लेयर का पॉइंट रिचार्ज सफल रहा!", newMasterBalance: master.points });
});
// 🏠 लॉगिन पेज लोड करने का रूट
app.get('/login', (req, res) => {
    res.sendFile(path.join(__dirname, 'login.html'));
});

// 🔐 लॉगिन वेरिफिकेशन रूट
app.post('/api/auth/login', (req, res) => {
    const { username, password } = req.body;
    let db = loadDB();

    // 1. सुपर एडमिन चेक
    if (username === "superadmin" && password === "123") {
        return res.json({ success: true, redirect: "/" });
    }

    // 2. मास्टर चेक
    const master = db.masterAccounts.find(m => m.username === username);
    if (master) {
        if (master.password !== password) return res.json({ success: false, message: "गलत पासवर्ड!" });
        if (master.status === "BLOCKED") return res.json({ success: false, message: "आपकी मास्टर आईडी ब्लॉक है!" });
        return res.json({ success: true, redirect: "/master-dashboard" });
    }

    // 3. प्लेयर चेक
    let foundPlayer = null;
    let playerMaster = null;
    db.masterAccounts.forEach(m => {
        if (m.players) {
            const p = m.players.find(pl => pl.username === username);
            if (p) { foundPlayer = p; playerMaster = m; }
        }
    });

    if (foundPlayer) {
        if (foundPlayer.password !== password) return res.json({ success: false, message: "गलत पासवर्ड!" });
        if (playerMaster.status === "BLOCKED" || foundPlayer.status === "BLOCKED") {
            return res.json({ success: false, message: "आपकी आईडी ब्लॉक कर दी गई है!" });
        }
        return res.json({ success: true, redirect: "/player" });
    }

    return res.json({ success: false, message: "यूजरनेम नहीं मिला!" });
});
app.get('/login', (req, res) => {
    res.sendFile(__dirname + '/safe-login.html');
;
});
