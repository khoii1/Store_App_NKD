const jwt = require('jsonwebtoken');
const User = require('../models/user');
const vendor = require('../models/vendor');

// Middleware xác thực người dùng
// Middleware này kiểm tra xem người dùng đã được xác thực hay chưa
const auth = async (req, res, next) => {
    try {
        // Lấy token từ header yêu cầu
        const token = req.header('x-auth-token');

        // Nếu không có token được cung cấp, trả về phản hồi 401 (không được phép truy cập) với thông báo lỗi
        if (!token) {
            return res.status(401).json({ msg: "Không có token xác thực, quyền truy cập bị từ chối." });
        }

        // Xác minh token JWT bằng khóa bí mật
        const verified = jwt.verify(token, "passwordKey");

        // Nếu việc xác minh token thất bại, trả về 401
        if (!verified) {
            return res.status(401).json({ msg: "Xác minh token thất bại, quyền truy cập bị từ chối." });
        }

        const user = await User.findById(verified.id) || await vendor.findById(verified.id);
        // Kiểm tra xem người dùng (user) có tồn tại hay không
        if (!user) {
            // Nếu không tìm thấy người dùng, trả về mã lỗi 401 (Unauthorized) và thông báo lỗi
            return res.status(401).json({ msg: "Người dùng hoặc nhà cung cấp không tồn tại, quyền truy cập bị từ chối." });
        }

        // Gán thông tin người dùng đã xác thực (dù là người dùng thông thường hay nhà cung cấp) vào đối tượng request
        // Điều này cho phép các middleware hoặc route handler tiếp theo có thể truy cập thông tin người dùng
        req.user = user;

        // Gán token vào đối tượng request, đề phòng trường hợp cần sử dụng sau này
        req.token = token;

        // Chuyển sang middleware hoặc route handler tiếp theo
        next();

    } catch (e) {
        // Xử lý lỗi nếu có lỗi xảy ra trong quá trình thực hiện
        res.status(500).json({ error: e.message });
    }

};
const vendorAuth = (req, res, next) => {
    try {
        // Kiểm tra xem người dùng thực hiện yêu cầu có phải là nhà cung cấp (vendor) hay không, 
        // bằng cách kiểm tra thuộc tính "role" của người dùng.
        if (!req.user.role || req.user.role !== "vendor") {
            // Nếu người dùng không phải là nhà cung cấp, trả về phản hồi 403 (Forbidden - Bị cấm) 
            // với thông báo lỗi.
            return res.status(403).json({ msg: "Truy cập bị từ chối, chỉ nhà cung cấp được phép truy cập." });
        }

        // Nếu người dùng là nhà cung cấp, tiếp tục đến middleware hoặc route handler tiếp theo.
        next();
    } catch (e) {
        // Xử lý lỗi nếu có lỗi xảy ra trong quá trình thực hiện.
        return res.status(500).json({ error: e.message });
    }
};

module.exports = { auth, vendorAuth };
