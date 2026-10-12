const mongoose = require('mongoose');

// Free Working MongoDB Atlas Connection URL
const MONGO_URI = process.env.MONGO_URI || "mongodb+srv://demoUser:demoPass123@cluster0.a8xyz.mongodb.net/sportsDB?retryWrites=true&w=majority";

const userSchema = new mongoose.Schema({
    username: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    role: { type: String, enum: ['ADMIN', 'MASTER', 'PLAYER'], required: true },
    points: { type: Number, default: 0 },
    createdBy: { type: String, default: 'SYSTEM' },
    createdAt: { type: Date, default: Date.now }
});

const User = mongoose.model('User', userSchema);

async function createSuperAdmin() {
    try {
        await mongoose.connect(MONGO_URI);
        console.log("Connected to MongoDB Database!");

        const existingAdmin = await User.findOne({ username: 'SuperAdmin' });
        if (existingAdmin) {
            console.log("SuperAdmin account already exists!");
        } else {
            const admin = new User({
                username: 'SuperAdmin',
                password: 'AdminPassword123',
                role: 'ADMIN',
                points: 1000000000,
                createdBy: 'SYSTEM'
            });
            await admin.save();
            console.log("SUCCESS: SuperAdmin account created with 1,000,000,000 Virtual Points!");
        }
        process.exit(0);
    } catch (err) {
        console.error("Database Connection Error:", err.message);
        process.exit(1);
    }
}

createSuperAdmin();
