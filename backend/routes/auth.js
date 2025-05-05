const express = require('express'); // Express.js - Framework để tạo API
const bcrypt = require('bcryptjs'); // bcryptjs - Thư viện để mã hóa mật khẩu
const jwt = require('jsonwebtoken'); // jsonwebtoken - Thư viện tạo JWT token
const User = require('../models/user'); // Import mô hình User để làm việc với MongoDB

// Tạo Router cho API xác thực
const authRouter = express.Router();

// API đăng ký người dùng
authRouter.post('/api/signup', async (req, res) => {
    try {
        // Lấy dữ liệu từ request body
        const { fullName, email, password } = req.body;

        // Kiểm tra xem email đã tồn tại trong database chưa
        const existingEmail = await User.findOne({ email });
        if (existingEmail) {
            return res.status(400).json({ msg: "Email cung cấp đã tồn tại" });
        }

        // Tạo một chuỗi salt để mã hóa mật khẩu
        const salt = await bcrypt.genSalt(10);

        // Mã hóa mật khẩu bằng bcrypt
        const hashedPassword = await bcrypt.hash(password, salt);

        // Tạo một người dùng mới với thông tin đã mã hóa
        let user = new User({ fullName, email, password: hashedPassword });

        // Lưu người dùng vào cơ sở dữ liệu
        user = await user.save();

        // Trả về thông tin người dùng (không bao gồm mật khẩu)
        res.json({ user });
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

// API đăng nhập người dùng
authRouter.post('/api/signin', async (req, res) => {
    try {
        // Lấy email và password từ request body
        const { email, password } = req.body;

        // Tìm người dùng trong database theo email
        const findUser = await User.findOne({ email });
        if (!findUser) {
            return res.status(400).json({ msg: "User not found with this email" });
        } else {
            const isMatch = await bcrypt.compare(password, findUser.password);
            if (!isMatch) {
                return res.status(400).json({ msg: 'Incorrect Password' });
            } else {
                const token = jwt.sign({ id: findUser._id }, "passwordKey");

                const { password: _, ...userWithoutPassword } = findUser._doc;

                res.json({ token, user: userWithoutPassword });
            }
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

//Put route for updating user's state, city and locality
authRouter.put('/api/users/:id', async (req, res) => {
    try {
        //Extract the 'id' parameter from the request URL
        const { id } = req.params;

        //Extract the "state", "city" and locality fields from the request body
        const { state, city, locality } = req.body;

        //Find the user by their ID and update the state, city and locality
        // the {new:true} option ensures the updated document is returned
        const updatedUser = await User.findByIdAndUpdate(
            id,
            { state, city, locality },
            { new: true },
        );
        if (!updatedUser) {
            return res.status(404).json({ error: "User not found" });
        }
        return res.status(200).json(updatedUser);
    } catch (error) {
        res.status(500).json({ message: "Failed to update user." });
    }
});

authRouter.get('/api/users', async (req, res) => {
    try {
        const users = await User.find().select('-password'); // Loại bỏ trường password
        return res.status(200).json(users);
    } catch (e) {
        return res.status(500).json({ error: e.message }); // Sửa lỗi cú pháp và trả về lỗi chi tiết
    }
});
module.exports = authRouter;