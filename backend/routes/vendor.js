const express = require('express');
const Vendor = require('../models/vendor');
const vendorRouter = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken'); // jsonwebtoken - Thư viện tạo JWT token


vendorRouter.post('/api/vendor/signup', async (req, res) => {
    try {
        // Lấy dữ liệu từ request body
        const { fullName, email, password } = req.body;

        // Kiểm tra xem email đã tồn tại trong database chưa
        const existingEmail = await Vendor.findOne({ email });
        if (existingEmail) {
            return res.status(400).json({ msg: "vendor cung cấp đã tồn tại" });
        }

        // Tạo một chuỗi salt để mã hóa mật khẩu
        const salt = await bcrypt.genSalt(10);

        // Mã hóa mật khẩu bằng bcrypt
        const hashedPassword = await bcrypt.hash(password, salt);

        // Tạo một người dùng mới với thông tin đã mã hóa
        let vendor = new Vendor({ fullName, email, password: hashedPassword });

        // Lưu người dùng vào cơ sở dữ liệu
        vendor = await vendor.save();

        // Trả về thông tin người dùng (không bao gồm mật khẩu)
        res.json({ vendor });
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});
vendorRouter.post('/api/vendor/signin', async (req, res) => {
    try {
        // Lấy email và password từ request body
        const { email, password } = req.body;

        // Tìm người dùng trong database theo email
        const findUser = await Vendor.findOne({ email });
        if (!findUser) {
            return res.status(400).json({ msg: "Vendor not found with this email" });
        }

        // So sánh mật khẩu nhập vào với mật khẩu trong database
        const isMatch = await bcrypt.compare(password, findUser.password);
        if (!isMatch) {
            return res.status(400).json({ msg: 'Incorrect Password' });
        }

        // Tạo JWT token để xác thực người dùng
        const token = jwt.sign({ id: findUser._id }, "passwordKey", { expiresIn: "1h" });

        // Loại bỏ password trước khi gửi dữ liệu trả về
        const { password: _, ...vendorWithoutPassword } = findUser._doc;

        // Trả về token và thông tin người dùng (không chứa mật khẩu)
        res.json({ token, vendor: vendorWithoutPassword });
    } catch (error) {
        // Xử lý lỗi nếu có bất kỳ vấn đề nào xảy ra
        res.status(500).json({ error: error.message });
    }
});
// fetch all vendors (exclude password)
vendorRouter.get('/api/vendors', async (req, res) => {
    try {
        const vendors = await Vendor.find().select('-password'); // Exclude password field
        return res.status(200).json(vendors);
    } catch (e) {
        return res.status(500).json({ error: e.message }); // Trả về lỗi chi tiết với mã trạng thái 500
    }
});

module.exports = vendorRouter;
module.exports = vendorRouter;