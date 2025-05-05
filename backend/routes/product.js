const express = require('express');
const Product = require('../models/product');
const productRouter = express.Router();
const { auth, vendorAuth } = require('../middleware/auth');

productRouter.post('/api/add-product', auth, vendorAuth, async (req, res) => {
    try {
        const { productName, productPrice, quantity, description, category, vendorId, fullName, subCategory, images } = req.body;
        const product = new Product({ productName, productPrice, quantity, description, category, vendorId, fullName, subCategory, images });
        await product.save();
        return res.status(201).send(product);
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

productRouter.get('/api/popular-products', async (req, res) => {
    try {
        const product = await Product.find({ popular: true });
        if (!product || product.length === 0) {
            return res.status(404).json({ msg: "products not found" });
        } else {
            return res.status(200).json(product);
        }
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});
productRouter.get('/api/recommend-products', async (req, res) => {
    try {
        const product = await Product.find({ recommend: true });
        if (!product || product.length === 0) {
            return res.status(404).json({ msg: "products not found" });
        } else {
            return res.status(200).json(product);
        }
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});
productRouter.get('/api/products-by-category/:category', async (req, res) => {
    try {
        const { category } = req.params;
        const products = await Product.find({ category, popular: true });
        if (!products || products.length == 0) { // Changed == to === for strict equality
            return res.status(404).json({ msg: "Product not found" }); // Corrected "no" to "not" and added curly braces for the JSON object
        } else {
            return res.status(200).json(products);
        }
    } catch (e) {
        res.status(500).json({ error: e.message }); // Added curly braces and key for the error message
    }
});
// Tuyến đường mới để truy xuất các sản phẩm liên quan theo danh mục phụ
productRouter.get('/api/related-products-by-subcategory/:productId', async (req, res) => {
    try {
        const { productId } = req.params;

        // Đầu tiên tìm sản phẩm để lấy danh mục phụ của nó
        const product = await Product.findById(productId);

        if (!product) {
            return res.status(404).json({ msg: "Không tìm thấy sản phẩm" });
        } else {
            // Tìm các sản phẩm liên quan dựa trên danh mục phụ của sản phẩm đã truy xuất
            const relatedProducts = await Product.find({
                subCategory: product.subCategory,
                _id: { $ne: productId } // Loại trừ sản phẩm hiện tại
            });
            if (!relatedProducts || relatedProducts.length === 0) {
                return res.status(404).json({ msg: "Không tìm thấy sản phẩm liên quan" });
            }

            return res.status(200).json(relatedProducts);
        }
    } catch (e) {
        return res.status(500).json({ error: e.message });
    }
});
productRouter.get('/api/top-rated-products', async (req, res) => {
    try {
        const topRatedProducts = await Product.find({}).sort({ averageRating: -1 }).limit(10); // Hoặc Product.find()

        if (!topRatedProducts || topRatedProducts.length === 0) {
            return res.status(404).json({ msg: "No top-rated products found" });
        }

        return res.status(200).json(topRatedProducts);
    } catch (e) {
        return res.status(500).json({ error: e.message });
    }
});

productRouter.get('/api/products-by-subcategory/:subCategory', async (req, res) => {
    try {
        const { subCategory } = req.params;
        const products = await Product.find({ subCategory: subCategory });
        if (!products || products.length === 0) {
            return res.status(404).json({ msg: "No Products found in this subcategory" });
        }
        return res.status(200).json(products);
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});
productRouter.get('/api/search-products', async (req, res) => {
    try {
        const { query } = req.query;

        // Validate that a query parameter is provided
        // if missing, return a 400 status with an error message
        if (!query) {
            return res.status(400).json({ msg: "Query parameter required" });
        }

        // Search for the Product collection for documents where either 'productName' or 'description'
        // contains the specified query String;
        const products = await Product.find({
            $or: [
                // Regex will match any productName containing the query String,
                // For example, if the user search for "apple", the regex will check
                // if "apple" is part of any productName, so product name "Green Apple pie",
                // //or "Fresh Apples", would all match because they contain the world "apple"
                { productName: { $regex: query, $options: 'i' } },
                { description: { $regex: query, $options: 'i' } }
            ]
        });

        //check if any products were found, if no product match the query
        //return a 404 status code with a message
        if (!products || products.length === 0) {
            return res.status(404).json({ msg: "No products found matching the query" });
        }

        return res.status(200).json(products);

    } catch (error) {
        console.error(error);
        res.status(500).json({ error: e.message });
    }
});

productRouter.put('/api/edit-product/:productId', auth, vendorAuth, async (req, res) => {
    try {
        // Extract product ID from the request parameter
        const { productId } = req.params;

        // Check if the product exists and if the vendor is authorized to edit it
        const product = await Product.findById(productId);
        if (!product) {
            return res.status(404).json({ msg: "Product not found" });
        }
        if (product.vendorId.toString() !== req.user.id) {
            return res.status(403).json({ msg: "Unauthorized to edit this product" });
        }

        // Destructure req.body to exclude vendorId
        const { vendorId, ...updateData } = req.body;
        // Update the product with the fields provided in updateData
        await Product.findByIdAndUpdate(productId,
            { $set: updateData },//update only fields in the updateData
            { new: true });//return the updated product document in the response

        //return the updated product with 200 ok status
        res.status(200).json(updatedProduct);
    } catch (e) {
        return res.status(500).json({ msg: "Server error", error: error.message });
    }
});
module.exports = productRouter;
