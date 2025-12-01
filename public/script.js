document.addEventListener('DOMContentLoaded', () => {
    const bookingModal = document.getElementById('bookingModal');
    const closeBtn = document.querySelector('.close-btn');
    const doctorCards = document.querySelectorAll('.doctor-card');
    const modalDoctorName = document.getElementById('modal-doctor-name');
    const bookingForm = document.getElementById('bookingForm');

    // Chatbot functionality
    const chatbotIcon = document.getElementById('chatbot-icon');
    const chatbox = document.getElementById('chatbox');

    chatbotIcon.addEventListener('click', () => {
        chatbox.classList.toggle('active');
    });

    // Handle opening the modal
    doctorCards.forEach(card => {
        card.querySelector('.book-btn').addEventListener('click', () => {
            const doctorName = card.dataset.doctor;
            modalDoctorName.textContent = `Book with ${doctorName}`;
            bookingModal.style.display = 'flex';
        });
    });

    // Handle closing the modal
    closeBtn.addEventListener('click', () => {
        bookingModal.style.display = 'none';
    });

    // Close modal if user clicks outside of it
    window.addEventListener('click', (event) => {
        if (event.target === bookingModal) {
            bookingModal.style.display = 'none';
        }
    });

    // Handle form submission
    bookingForm.addEventListener('submit', async (e) => {
        e.preventDefault(); // Prevent the default form submission

        // Collect form data
        const formData = {
            doctorName: modalDoctorName.textContent.replace('Book with ', ''),
            name: document.getElementById('name').value,
            phone: document.getElementById('phone').value,
            age: document.getElementById('age').value,
            sex: document.getElementById('sex').value,
            illness: document.getElementById('illness').value,
        };

        console.log('Form Data:', formData); // For debugging

        try {
            const response = await fetch('/api/book-appointment', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(formData),
            });

            if (response.ok) {
                alert('Your appointment request has been sent successfully!');
                bookingModal.style.display = 'none'; // Close the modal on success
                bookingForm.reset(); // Clear the form
            } else {
                alert('Failed to send booking request. Please try again.');
            }
        } catch (error) {
            console.error('Error submitting form:', error);
            alert('An error occurred. Please check your network connection.');
        }
    });
});