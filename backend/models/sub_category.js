const mongooge = require('mongoose');

const subCategorySchema = mongooge.Schema({
    categoryId: {
        type: String,
        required: true,
    },
    categoryName: {
        type: String,
        required: true,
    },
    image: {
        type: String,
        required: true,
    },
    subCategoryName: {
        type: String,
        required: true,
    }
});

const subCategory = mongooge.model("SubCategories", subCategorySchema);

module.exports = subCategory;