const express = require('express');
const mongoose = require('mongoose');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Connect to MongoDB
mongoose.connect('mongodb+srv://anujtiwari4454:JJqGzK3OKjq4cMDs@cluster0.humnu.mongodb.net/formDetails', { 
 
})
.then(() => console.log("MongoDB connected"))
.catch(err => console.log(err));

// Schema for form data
const formSchema = new mongoose.Schema({
  name: String,
  dob: Date,
  gender: String,
  profileImage: String
});

const Form = mongoose.model('Form', formSchema);

// Multer setup for image upload
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/');
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + path.extname(file.originalname));
  }
});

const upload = multer({ storage });

// API to handle form submission
app.post('/submit-form', upload.single('profileImage'), async (req, res) => {
  try {
    const { name, dob, gender } = req.body;

    const formData = new Form({
      name,
      dob,
      gender,
      profileImage: req.file ? req.file.path : null
    });

    await formData.save();

    res.status(200).json({ message: "Form data saved successfully!" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Error saving form data" });
  }
});

// API to serve the uploaded images
app.use('/uploads', express.static('uploads'));

// Start the server
const PORT = process.env.PORT || 8000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
