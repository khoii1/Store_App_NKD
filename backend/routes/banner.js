const express = require('express');
const Banner = require('../models/banner');
const bannerRouter = express.Router();

bannerRouter.post('/api/banner', async (req, res) => {
    try {
        const { image } = req.body;
        const banner = new Banner({ image });
        await banner.save();
        return res.status(201).send(banner);
    } catch (error) {
        res.status(500).json({ error: error.message }); // Sửa e.message thành error.message
    }
});

bannerRouter.get('/api/banner', async (req, res) => {
    try {
        const banners = await Banner.find();
        return res.status(200).send(banners); // Sửa banner thành banners
    } catch (error) {
        res.status(500).json({ error: error.message }); // Sửa e.message thành error.message
    }
});

module.exports = bannerRouter;
