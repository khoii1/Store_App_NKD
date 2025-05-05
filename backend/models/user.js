// trung gian giua aws va mongo
const mongoose = require('mongoose');

// luoc do nguoi dung
const userSchema = mongoose.Schema({
    fullName: {
        type: String,
        required: true,
        trim: true,
    },
    email: {
        type: String,
        required: true,
        trim: true,
        validate: {
            validator: (value) => {
                const result = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                return result.test(value);
            },
            message: "Vui lòng nhập email hợp lệ",
        }
    },
    state: {
        type: String,
        default: "",
    },
    city: {
        type: String,
        default: "",
    },
    locality: {
        type: String,
        default: "",
    },
    password: {
        type: String,
        required: true,
        validate: {
            validator: (value) => {
                // kiem tra du dieu kien k it nhat 8 ki tu 
                return value.length >= 8;
            },
            message: " Mật khẩu phải ít nhất 8 kí tự",
        }

    },

});
// cho nay tao ra mo hinh ket noi 
const User = mongoose.model("User", userSchema);
module.exports = User;