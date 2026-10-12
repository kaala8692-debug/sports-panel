const express = require('express');
const fs = require('fs');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors());
app.use(express.urlencoded({ extended: true }));
app.use(express.static('public'));

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
