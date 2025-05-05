const express = require('express');
const orderRouter = express.Router();
const Order = require('../models/order');
const { auth, vendorAuth } = require('../middleware/auth');

//Post route for creating orders
orderRouter.post('/api/orders', auth, async (req, res) => {
    try {
        const { fullName, email, state, city, locality, productName, productPrice, quantity, category, image, vendorId, buyerId } = req.body;
        const createdAt = new Date(); // Use the Date object directly
        const order = new Order({
            fullName, email, state, city, locality, productName, productPrice, quantity, category, image, vendorId, buyerId, createdAt
        });

        const savedOrder = await order.save(); // Use await to ensure saving is complete
        return res.status(201).json(savedOrder); // Respond with the saved order
    } catch (error) {
        console.error("Error creating order:", error); // Log the error for debugging
        res.status(500).json({ error: error.message }); // Use the 'error' object from the catch block
    }
});

// GET route để lấy danh sách đơn hàng theo ID người mua
orderRouter.get('/api/orders/:buyerId', auth, async (req, res) => {
    try {
        // Lấy buyerId từ tham số của request
        const { buyerId } = req.params;

        // Tìm tất cả đơn hàng trong cơ sở dữ liệu khớp với buyerId
        const orders = await Order.find({ buyerId });

        // Nếu không có đơn hàng nào được tìm thấy, trả về mã trạng thái 404 kèm theo thông báo
        if (orders.length === 0) {
            return res.status(404).json({ msg: 'Không tìm thấy đơn hàng nào cho người mua này' });
        }

        // Nếu tìm thấy đơn hàng, trả về chúng với mã trạng thái 200
        return res.status(200).json(orders);
    } catch (e) {
        // Xử lý mọi lỗi xảy ra trong quá trình truy xuất đơn hàng
        res.status(500).json({ error: e.message });
    }
});
orderRouter.delete("/api/orders/:id", auth, async (req, res) => {
    try {
        // Lấy ID từ tham số yêu cầu
        const { id } = req.params;

        // Tìm và xóa đơn hàng từ cơ sở dữ liệu dựa trên ID đã lấy được
        const deletedOrder = await Order.findByIdAndDelete(id);

        // Kiểm tra xem đơn hàng có tồn tại và đã được xóa thành công hay không
        if (!deletedOrder) {
            // Nếu không tìm thấy đơn hàng với ID đã cung cấp, trả về mã lỗi 404 (Không tìm thấy)
            return res.status(404).json({ msg: "Không tìm thấy đơn hàng" });
        } else {
            // Nếu đơn hàng được xóa thành công, trả về mã trạng thái 200 (Thành công) cùng thông báo
            return res.status(200).json({ msg: "Đơn hàng đã được xóa thành công" });
        }
    } catch (e) {
        // Nếu có lỗi xảy ra trong quá trình xử lý, trả về mã trạng thái 500 (Lỗi máy chủ nội bộ) cùng thông báo lỗi
        res.status(500).json({ error: e.message });
    }
});


orderRouter.get('/api/orders/vendors/:vendorId', auth, vendorAuth, async (req, res) => {
    try {
        // Lấy vendorId từ tham số của request
        const { vendorId } = req.params;

        // Tìm tất cả đơn hàng trong cơ sở dữ liệu khớp với vendorId
        const orders = await Order.find({ vendorId });

        // Nếu không có đơn hàng nào được tìm thấy, trả về mã trạng thái 404 kèm theo thông báo
        if (orders.length === 0) {
            return res.status(404).json({ msg: 'Không tìm thấy đơn hàng nào cho nhà cung cấp này' });
        }

        // Nếu tìm thấy đơn hàng, trả về chúng với mã trạng thái 200
        return res.status(200).json(orders);
    } catch (e) {
        // Xử lý mọi lỗi xảy ra trong quá trình truy xuất đơn hàng
        res.status(500).json({ error: e.message });
    }
});
orderRouter.patch('/api/orders/:id/delivered', async (req, res) => {
    try {
        const { id } = req.params; // Lấy ID đơn hàng từ request parameters
        const updatedOrder = await Order.findByIdAndUpdate(
            id, // ID của đơn hàng cần cập nhật
            { delivered: true, processing: false }, // Dữ liệu cần cập nhật: đặt trạng thái 'delivered' thành true
            { new: true } // Tùy chọn này để trả về document đã được cập nhật
        );

        // Nếu không tìm thấy đơn hàng với ID cung cấp
        if (!updatedOrder) {
            return res.status(404).json({ msg: "Order not found" }); // Trả về lỗi 404
        } else {
            // Nếu cập nhật thành công, trả về đơn hàng đã được cập nhật với status 200
            return res.status(200).json(updatedOrder);
        }
    } catch (error) {
        // Xử lý lỗi nếu có bất kỳ lỗi nào xảy ra trong quá trình thực thi
        console.error("Error updating order:", error); // Ghi lại lỗi ra console (cho mục đích debug)
        return res.status(500).json({ msg: "Server error" }); // Trả về lỗi 500 nếu có lỗi server
    }
});

orderRouter.patch('/api/orders/:id/processing', async (req, res) => {
    try {
        const { id } = req.params; // Lấy ID đơn hàng từ request parameters
        const updatedOrder = await Order.findByIdAndUpdate(
            id, // ID của đơn hàng cần cập nhật
            { processing: false, delivered: false }, // Dữ liệu cần cập nhật: đặt trạng thái 'delivered' thành true
            { new: true } // Tùy chọn này để trả về document đã được cập nhật
        );

        // Nếu không tìm thấy đơn hàng với ID cung cấp
        if (!updatedOrder) {
            return res.status(404).json({ msg: "Order not found" }); // Trả về lỗi 404
        } else {
            // Nếu cập nhật thành công, trả về đơn hàng đã được cập nhật với status 200
            return res.status(200).json(updatedOrder);
        }
    } catch (error) {
        // Xử lý lỗi nếu có bất kỳ lỗi nào xảy ra trong quá trình thực thi
        console.error("Error updating order:", error); // Ghi lại lỗi ra console (cho mục đích debug)
        return res.status(500).json({ msg: "Server error" }); // Trả về lỗi 500 nếu có lỗi server
    }
});
orderRouter.get('/api/orders', async (req, res) => {
    try {
        const orders = await Order.find();
        return res.status(200).json(orders);
    } catch (e) {
        return res.status(500).json({ error: e.message });
    }
});
module.exports = orderRouter;