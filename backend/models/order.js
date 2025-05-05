const mongoose = require('mongoose');

const ordersSchema = new mongoose.Schema({
    fullName: {
        type: String,
        required: true
    },
    email: {
        type: String,
        required: true
    },
    state: {
        type: String,
        required: true,
    },
    city: {
        type: String,
        required: true,
    },
    locality: {
        type: String,
        required: true,
    },
    productName: {
        type: String,
        required: true
    },
    quantity: {
        type: Number,
        required: true
    },
    category: {
        type: String,
        required: true
    },
    image: {
        type: String,
        required: true,
    },
    buyerId: {
        type: String,
        required: true,
    },
    vendorId: {
        type: String,
        required: true,
    },
    processing: {
        type: Boolean,
        default: true,
    },
    delivered: {
        type: Boolean,
        default: true,
    },
    createdAt: {
        type: Number,
        default: true, // Set default value to current time
    },
    productPrice: {
        type: Number,
        required: true
    }
});

const Order = mongoose.model("Order", ordersSchema); // Corrected model name
module.exports = Order;