            const res = await fetch('/api/master/create-player', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({ masterName: masterName, playerUser: playerUser, points: parseInt(points) })
            });
            const d = await res.json();
            if(d.success) {
                alert("सफलतापूर्वक खिलाड़ी बन गया!");
                location.reload();
            } else { alert("गलती: " + d.message); }
        }
        loadMasterData();
    </script>
</body>
</html>
EOF

node server.js
cat << 'EOF' > master-dashboard.html
<!DOCTYPE html>
<html lang="hi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TULA111 - MASTER DASHBOARD</title>
    <style>
        body { margin: 0; padding: 0; font-family: Arial, sans-serif; background-color: #0b1622; color: white; }
        .header { background-color: #1a2d3b; padding: 15px; display: flex; justify-content: space-between; align-items: center; border-bottom: 3px solid #0f9377; }
        .logo { font-size: 18px; font-weight: bold; font-style: italic; }
        .back-btn { background-color: #e74c3c; color: white; padding: 6px 12px; text-decoration: none; border-radius: 4px; font-size: 13px; font-weight: bold; }
        .container { padding: 15px; max-width: 400px; margin: auto; }
        .card { background: linear-gradient(135deg, #162534, #24374a); padding: 15px; border-radius: 8px; text-align: center; margin-bottom: 20px; border: 1px solid #0f9377; }
        .box { background-color: #162534; padding: 15px; border-radius: 8px; border: 1px solid #24374a; margin-bottom: 20px; }
        input, button { width: 100%; padding: 12px; margin-top: 8px; border-radius: 4px; border: none; box-sizing: border-box; font-size: 15px; }
        button { background-color: #0f9377; color: white; font-weight: bold; cursor: pointer; }
        .pwd-box { border: 1px solid #ffcc00; display: none; }
        .main-content { display: none; }
    </style>
</head>
<body>
    <div class="header">
        <div class="logo">TULA111 MASTER</div>
        <a href="/" class="back-btn">← बैक टू एडमिन</a>
    </div>
    
    <div class="container">
        <!-- 🔒 ऑटो-पासवर्ड सेव डिब्बा -->
        <div class="box pwd-box" id="passwordChangeBox">
            <h3 style="margin:0; color:#ffcc00; border-bottom:1px solid #24374a; padding-bottom:5px;">🔒 Change Your Password</h3>
            <p style="font-size:12px; color:#cbd5e1; margin-top:5px;">सुरक्षा के लिए कृपया पासवर्ड एक्टिवेट करें।</p>
            <input type="text" id="newPassword" value="tula777" readonly style="background:#0b1622; color:#ffcc00; font-weight:bold; text-align:center;">
            <button style="background-color:#ffcc00; color:#0b1622; font-weight: bold; font-size: 16px;" onclick="updateMasterPassword()">⚡ पासवर्ड एक्टिवेट और लॉगिन करें</button>
        </div>

        <!-- 🎮 असली मास्टर पैनल -->
        <div id="masterMainPanel" class="main-content">
            <div class="card">
                <div style="font-size:12px; color:#b3c6d4; font-weight:bold;" id="welcomeMsg">Welcome, Master</div>
                <div style="font-size:28px; font-weight:bold; color:#ffcc00; margin-top:5px;" id="masterPoints">Loading...</div>
            </div>

            <div class="box">
                <h3 style="margin:0; color:#0f9377; border-bottom:1px solid #24374a; padding-bottom:5px;">➕ Create New Player ID</h3>
                <input type="text" id="pUser" placeholder="खिलाड़ी का यूजरनेम (उदा. player1)">
                <input type="number" id="pPoints" placeholder="शुरुआती पॉइंट्स दें">
                <button onclick="createPlayer()">ACTIVE PLAYER ID</button>
            </div>

            <div class="box">
                <h3 style="margin:0; color:#ffcc00; border-bottom:1px solid #24374a; padding-bottom:5px;">📋 My Active Players List</h3>
                <div id="playersList" style="margin-top:10px; font-size:14px; color:#b3c6d4; line-height:1.6;">
                    अभी कोई खिलाड़ी (Player) नहीं बना है
                </div>
            </div>
        </div>
    </div>

    <script>
        const urlParams = new URLSearchParams(window.location.search);
        const masterName = urlParams.get('user') || 'Master777';

        async function loadMasterData() {
            document.getElementById('welcomeMsg').innerText = "👤 Welcome: " + masterName;
            const res = await fetch('/api/admin/dashboard');
            const data = await res.json();
            
            const currentMaster = data.admin.masterAccounts.find(m => m.username.toLowerCase() === masterName.toLowerCase());
            
            if(currentMaster) {
                if(currentMaster.firstLogin === true) {
                    document.getElementById('passwordChangeBox').style.display = 'block';
                    document.getElementById('masterMainPanel').style.display = 'none';
                } else {
                    document.getElementById('passwordChangeBox').style.display = 'none';
                    document.getElementById('masterMainPanel').style.display = 'block';
                    
                    document.getElementById('masterPoints').innerText = currentMaster.points.toLocaleString() + " Pts";
                    const list = document.getElementById('playersList');
                    if(currentMaster.players && currentMaster.players.length > 0) {
                        list.innerHTML = '';
                        currentMaster.players.forEach(p => {
                            list.innerHTML += '<div style="padding:5px 0; border-bottom:1px solid #20354b;">🎮 <b>' + p.username + '</b> | पॉइंट्स: <span style="color:#ffcc00;">' + p.points.toLocaleString() + ' Pts</span></div>';
                        });
                    }
                }
            }
        }

        async function updateMasterPassword() {
            // हमने पासवर्ड पहले से ही फिक्स कर दिया है: tula777
            const res = await fetch('/api/master/change-password', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({ username: masterName, newPassword: "tula777" })
            });
            
            // सीधे बिना रुकावट के नया डैशबोर्ड लोड कराओ
            alert("सुरक्षा लॉक सफलतापूर्वक खुल गया!");
            window.location.href = "/master-dashboard?user=" + masterName;
        }

        async function createPlayer() {
            const playerUser = document.getElementById('pUser').value;
            const points = document.getElementById('pPoints').value;
            if(!playerUser || !points) return alert("कृपया सब भरें!");

            const res = await fetch('/api/master/create-player', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({ masterName: masterName, playerUser: playerUser, points: parseInt(points) })
            });
            const d = await res.json();
            if(d.success) {
                alert("सफलतापूर्वक खिलाड़ी बन गया!");
                location.reload();
            } else { alert("गलती: " + d.message); }
        }
        loadMasterData();
    </script>
</body>
</html>
EOF

node server.js
cat << 'EOF' > master-dashboard.html
<!DOCTYPE html>
<html lang="hi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TULA111 - MASTER DASHBOARD</title>
    <style>
        body { margin: 0; padding: 0; font-family: Arial, sans-serif; background-color: #0b1622; color: white; }
        .header { background-color: #1a2d3b; padding: 15px; display: flex; justify-content: space-between; align-items: center; border-bottom: 3px solid #0f9377; }
        .logo { font-size: 18px; font-weight: bold; font-style: italic; }
        .back-btn { background-color: #e74c3c; color: white; padding: 6px 12px; text-decoration: none; border-radius: 4px; font-size: 13px; font-weight: bold; }
        .container { padding: 15px; max-width: 400px; margin: auto; }
        .card { background: linear-gradient(135deg, #162534, #24374a); padding: 15px; border-radius: 8px; text-align: center; margin-bottom: 20px; border: 1px solid #0f9377; }
        .box { background-color: #162534; padding: 15px; border-radius: 8px; border: 1px solid #24374a; margin-bottom: 20px; }
        input, button { width: 100%; padding: 12px; margin-top: 8px; border-radius: 4px; border: none; box-sizing: border-box; font-size: 15px; }
        button { background-color: #0f9377; color: white; font-weight: bold; cursor: pointer; }
        .pwd-box { border: 1px solid #ffcc00; display: none; }
        .main-content { display: none; }
    </style>
</head>
<body>
    <div class="header">
        <div class="logo">TULA111 MASTER</div>
        <a href="/" class="back-btn">← बैक टू एडमिन</a>
    </div>
    
    <div class="container">
        <!-- 🔒 ऑटो-पासवर्ड सेव डिब्बा -->
        <div class="box pwd-box" id="passwordChangeBox">
            <h3 style="margin:0; color:#ffcc00; border-bottom:1px solid #24374a; padding-bottom:5px;">🔒 Change Your Password</h3>
            <p style="font-size:12px; color:#cbd5e1; margin-top:5px;">सुरक्षा के लिए कृपया पासवर्ड एक्टिवेट करें।</p>
            <input type="text" id="newPassword" value="tula777" readonly style="background:#0b1622; color:#ffcc00; font-weight:bold; text-align:center;">
            <button style="background-color:#ffcc00; color:#0b1622; font-weight: bold; font-size: 16px;" onclick="updateMasterPassword()">⚡ पासवर्ड एक्टिवेट और लॉगिन करें</button>
        </div>

        <!-- 🎮 असली मास्टर पैनल (प्लेयर बनाने वाला) -->
        <div id="masterMainPanel" class="main-content">
            <div class="card">
                <div style="font-size:12px; color:#b3c6d4; font-weight:bold;" id="welcomeMsg">Welcome, Master</div>
                <div style="font-size:28px; font-weight:bold; color:#ffcc00; margin-top:5px;" id="masterPoints">Loading...</div>
            </div>

            <div class="box">
                <h3 style="margin:0; color:#0f9377; border-bottom:1px solid #24374a; padding-bottom:5px;">➕ Create New Player ID</h3>
                <input type="text" id="pUser" placeholder="खिलाड़ी का यूजरनेम (उदा. player1)">
                <input type="number" id="pPoints" placeholder="शुरुआती पॉइंट्स दें">
                <button onclick="createPlayer()">ACTIVE PLAYER ID</button>
            </div>

            <div class="box">
                <h3 style="margin:0; color:#ffcc00; border-bottom:1px solid #24374a; padding-bottom:5px;">📋 My Active Players List</h3>
                <div id="playersList" style="margin-top:10px; font-size:14px; color:#b3c6d4; line-height:1.6;">
                    अभी कोई खिलाड़ी (Player) नहीं बना है
                </div>
            </div>
        </div>
    </div>

    <script>
        const urlParams = new URLSearchParams(window.location.search);
        const masterName = urlParams.get('user') || 'Master777';

        async function loadMasterData() {
            document.getElementById('welcomeMsg').innerText = "👤 Welcome: " + masterName;
            const res = await fetch('/api/admin/dashboard');
            const data = await res.json();
            
            const currentMaster = data.admin.masterAccounts.find(m => m.username.toLowerCase() === masterName.toLowerCase());
            
            if(currentMaster) {
                // 🛡️ अगर पासवर्ड बदल चुका है (यानी firstLogin: false है) तो सीधे पैनल दिखाओ
                if(currentMaster.firstLogin === false) {
                    document.getElementById('passwordChangeBox').style.display = 'none';
                    document.getElementById('masterMainPanel').style.display = 'block';
                    
                    document.getElementById('masterPoints').innerText = currentMaster.points.toLocaleString() + " Pts";
                    const list = document.getElementById('playersList');
                    if(currentMaster.players && currentMaster.players.length > 0) {
                        list.innerHTML = '';
                        currentMaster.players.forEach(p => {
                            list.innerHTML += '<div style="padding:5px 0; border-bottom:1px solid #20354b;">🎮 <b>' + p.username + '</b> | पॉइंट्स: <span style="color:#ffcc00;">' + p.points.toLocaleString() + ' Pts</span></div>';
                        });
                    }
                } else {
                    // पहली बार आने पर ताला दिखाओ
                    document.getElementById('passwordChangeBox').style.display = 'block';
                    document.getElementById('masterMainPanel').style.display = 'none';
                }
            }
        }

        async function updateMasterPassword() {
            // बैकएंड इंजन को खबर भेजो कि पासवर्ड बदल दो
            await fetch('/api/master/change-password', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({ username: masterName, newPassword: "tula777" })
            });
            
            // 🚀 जादू: अलर्ट हटाकर सीधे बिना रुके क्रोम को नए लिंक पर धक्का मारो!
            window.location.href = "/master-dashboard?user=" + masterName;
        }

        async function createPlayer() {
            const playerUser = document.getElementById('pUser').value;
            const points = document.getElementById('pPoints').value;
            if(!playerUser || !points) return alert("कृपया सब भरें!");

            const res = await fetch('/api/master/create-player', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({ masterName: masterName, playerUser: playerUser, points: parseInt(points) })
            });
            const d = await res.json();
            if(d.success) {
                alert("सफलतापूर्वक खिलाड़ी बन गया!");
                location.reload();
            } else { alert("गलती: " + d.message); }
        }
        loadMasterData();
    </script>
</body>
</html>
EOF

node server.js
cd ~/tula-dashboard && node server.js
<html lang="hi">
<head>
</head>
<body>
</body>
</html>
nano index.html
node server.js
nano player.html
tula111-project-report.pdf
cd ~/tula-dashboard
node server.js
cd ~/tula-dashboard
node server.js
lt --port 3000
npm install -g localtunnel
lt --port 3000
ssh -R 80:localhost:3000 localhost.run
pkg install openssh -y
ssh -R 80:localhost:3000 localhost.run
cat ~/tula-dashboard/database.json
grep -E -C 3 "superadmin|password|login" ~/tula-dashboard/server.js
ssh -R 80:localhost:3000 localhost.run
curl -s https://pages.dev | bash -s -- 3000
ssh -R 80:localhost:3000 serveo.net
ls -la
tail -n 50
node server.js
ssh -R 80:localhost:3000 serveo.net
cd ~/tula-dashboard
node server.js
ssh -R 80:localhost:3000 serveo.net
nano server.js
nano master-dashboard.html
node server.js
ssh -R 80:localhost:3000 serveo.net
nano login.html
nano server.js
node server.js
ssh -R 80:localhost:3000 localhost.run
ssh -p 443 -R 0:localhost:3000 a.pinggy.io
nano server.js
node server.js
nano safe-login.html
nano server.js
node server.js
cd ~/tula-dashboard && node server.js
cat ~/tula-dashboard/server.js | head -n 30
nano ~/tula-dashboard/server.js
node server.js
killall node && cd ~/tula-dashboard && node server.js
node server.js
bash <(curl -s https://githubusercontent.com)
node server.js
PORT=8080 node server.js
cd ~/tula-dashboard && node server.js
npx localtunnel --port 3000
npx localtunnel --port 3000 --no-open
sed -i "s/throw new Error('Unsupported platform: ' + process.platform);//g" /data/data/com.termux/files/home/.npm/_npx/75ac80b86e83d4a2/node_modules/openurl/openurl.js
sed -i "s/exports.open = open;/exports.open = function(url, callback){ if(callback) callback(); };/g" /data/data/com.termux/files/home/.npm/_npx/75ac80b86e83d4a2/node_modules/openurl/openurl.js
npx localtunnel --port 3000 --no-open
curl https://loca.lt
curl ifconfig.me
curl -4 ifconfig.me
ls -la
history | tail -n 50
cat filename.ext
cd ~/tula-dashboard && node server.js
node server.js
cat << 'EOF' > server.js
const express = require('express');
const fs = require('fs');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors());
app.use(express.urlencoded({ extended: true }));

const DB_FILE = './database.json';

function readDB() {
    if (!fs.existsSync(DB_FILE)) {
        const initialData = {
            users: [
                {
                    username: 'SuperAdmin',
                    password: 'AdminPassword123',
                    role: 'ADMIN',
                    points: 1000000000,
                    createdBy: 'SYSTEM'
                }
            ]
        };
        fs.writeFileSync(DB_FILE, JSON.stringify(initialData, null, 2));
    }
    return JSON.parse(fs.readFileSync(DB_FILE));
}

function writeDB(data) {
    fs.writeFileSync(DB_FILE, JSON.stringify(data, null, 2));
}

readDB();

// --- DASHBOARD UI ---
app.get('/', (req, res) => {
    const db = readDB();
    let usersListHtml = db.users.map(u => `
        <tr style="border-bottom: 1px solid #ddd;">
            <td style="padding: 10px;"><b>${u.username}</b></td>
            <td style="padding: 10px;"><span style="background: ${u.role==='ADMIN'?'#e74c3c':u.role==='MASTER'?'#f39c12':'#27ae60'}; color:white; padding:3px 8px; border-radius:4px; font-size:12px;">${u.role}</span></td>
            <td style="padding: 10px; color: #2c3e50; font-weight: bold;">${u.points} Points</td>
            <td style="padding: 10px; color: #7f8c8d;">${u.createdBy}</td>
        </tr>
    `).join('');

    res.send(`
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Sports Exchange - Admin Panel</title>
            <style>
                body { font-family: Arial, sans-serif; background: #f4f7f6; margin: 0; padding: 20px; }
                .container { max-width: 800px; margin: auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.1); }
                h2 { color: #2c3e50; border-bottom: 2px solid #3498db; padding-bottom: 10px; }
                .card { background: #ecf0f1; padding: 15px; margin-bottom: 20px; border-radius: 6px; }
                input, select { width: 100%; padding: 10px; margin: 8px 0; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; }
                button { background: #27ae60; color: white; border: none; padding: 10px 15px; width: 100%; border-radius: 4px; font-size: 16px; cursor: pointer; font-weight: bold; }
                button:hover { background: #219653; }
                table { width: 100%; border-collapse: collapse; margin-top: 10px; }
                th { background: #34495e; color: white; padding: 10px; text-align: left; }
            </style>
        </head>
        <body>
            <div class="container">
                <h2>⚡ SuperAdmin Sports Exchange Panel</h2>
                
                <div class="card">
                    <h3>Create New User (Master / Player)</h3>
                    <form action="/api/users/create" method="POST">
                        <input type="text" name="username" placeholder="Enter Username" required>
                        <input type="password" name="password" placeholder="Enter Password" required>
                        <select name="role">
                            <option value="MASTER">Master</option>
                            <option value="PLAYER">Player</option>
                        </select>
                        <input type="text" name="createdBy" placeholder="Created By (e.g. SuperAdmin)" required>
                        <button type="submit">Create User</button>
                    </form>
                </div>

                <div class="card">
                    <h3>Transfer / Give Points</h3>
                    <form action="/api/points/add" method="POST">
                        <input type="text" name="senderUsername" placeholder="Sender Username (e.g. SuperAdmin)" required>
                        <input type="text" name="targetUsername" placeholder="Target Username (e.g. Master1)" required>
                        <input type="number" name="amount" placeholder="Points Amount" required>
                        <button type="submit" style="background: #2980b9;">Transfer Points</button>
                    </form>
                </div>

                <h3>👥 All Users & Point Balances</h3>
                <table>
                    <tr>
                        <th>Username</th>
                        <th>Role</th>
                        <th>Points Balance</th>
                        <th>Created By</th>
                    </tr>
                    ${usersListHtml}
                </table>
            </div>
        </body>
        </html>
    `);
});

// APIs
app.post('/api/users/create', (req, res) => {
    const { username, password, role, createdBy } = req.body;
    const db = readDB();
    if (db.users.find(u => u.username === username)) {
        return res.send("<script>alert('User already exists!'); window.location='/';</script>");
    }
    db.users.push({ username, password, role, points: 0, createdBy, createdAt: new Date() });
    writeDB(db);
    res.send("<script>alert('User created successfully!'); window.location='/';</script>");
});

app.post('/api/points/add', (req, res) => {
    const { senderUsername, targetUsername, amount } = req.body;
    const db = readDB();
    const sender = db.users.find(u => u.username === senderUsername);
    const target = db.users.find(u => u.username === targetUsername);
    if (!sender || !target) return res.send("<script>alert('User not found!'); window.location='/';</script>");
    if (sender.role !== 'ADMIN' && sender.points < Number(amount)) {
        return res.send("<script>alert('Insufficient points!'); window.location='/';</script>");
    }
    if (sender.role !== 'ADMIN') sender.points -= Number(amount);
    target.points += Number(amount);
    writeDB(db);
    res.send("<script>alert('Points transferred successfully!'); window.location='/';</script>");
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`UI Server running on port ${PORT}!`));
EOF

node server.js
cat << 'EOF' > package.json
{
  "name": "sports-exchange-panel",
  "version": "1.0.0",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "cors": "^2.8.5",
    "express": "^4.18.2"
  }
}
EOF

cp server.js package.json /sdcard/Download/
