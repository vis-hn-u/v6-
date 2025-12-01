const express = require('express');
const path = require('path');
const fs = require('fs');
const nodemailer = require('nodemailer');
const app = express();
const port = process.env.PORT || 3000;

// Middleware to parse JSON bodies
app.use(express.json());

// Serve static files from the 'public' directory
app.use(express.static(path.join(__dirname, 'public')));

// Email Transporter Configuration
const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS
    }
});

// Health check endpoint
app.get('/api/health', (req, res) => {
    res.json({ status: 'ok', message: 'Backend is running' });
});

// Book Appointment Endpoint
app.post('/api/book-appointment', (req, res) => {
    const appointment = req.body;
    const filePath = path.join(__dirname, 'appointments.json');

    // Read existing appointments
    fs.readFile(filePath, 'utf8', (err, data) => {
        let appointments = [];
        if (!err && data) {
            try {
                appointments = JSON.parse(data);
            } catch (e) {
                console.error('Error parsing JSON:', e);
            }
        }

        // Add new appointment
        appointment.timestamp = new Date().toISOString();
        appointments.push(appointment);

        // Save back to file
        fs.writeFile(filePath, JSON.stringify(appointments, null, 2), (err) => {
            if (err) {
                console.error('Error writing to file:', err);
                return res.status(500).json({ message: 'Internal Server Error' });
            }

            // Send Email Notification
            if (process.env.EMAIL_USER && process.env.EMAIL_PASS) {
                const mailOptions = {
                    from: process.env.EMAIL_USER,
                    to: process.env.EMAIL_USER, // Sending to self/admin
                    subject: `New Appointment: ${appointment.name}`,
                    text: `
                        New Appointment Booking:
                        ------------------------
                        Doctor: ${appointment.doctorName}
                        Patient: ${appointment.name}
                        Phone: ${appointment.phone}
                        Age: ${appointment.age}
                        Sex: ${appointment.sex}
                        Reason: ${appointment.illness}
                        Time: ${appointment.timestamp}
                    `
                };

                transporter.sendMail(mailOptions, (error, info) => {
                    if (error) {
                        console.log('Error sending email:', error);
                    } else {
                        console.log('Email sent: ' + info.response);
                    }
                });
            } else {
                console.log('Email credentials not found, skipping email notification.');
            }

            res.status(201).json({ message: 'Appointment booked successfully' });
        });
    });
});

// Fallback to index.html for any other requests (optional, good for SPAs)
// app.get('*', (req, res) => {
//   res.sendFile(path.join(__dirname, 'public', 'index.html'));
// });

app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
