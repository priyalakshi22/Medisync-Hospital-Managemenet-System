# 🏥 MediSync HMS

**MediSync** is a role-based Hospital Management System that brings patient registration, appointments, clinical records, and billing into a single web application. It was built as a BSc Software Engineering project.

![PHP](https://img.shields.io/badge/PHP-8.x-777BB4?logo=php&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-8.x-4479A1?logo=mysql&logoColor=white)
![XAMPP](https://img.shields.io/badge/XAMPP-local%20server-FB7A24?logo=xampp&logoColor=white)
![Status](https://img.shields.io/badge/status-academic%20project-teal)

---

## 📌 Overview

Hospitals juggle many roles, each needing different views of the same data. MediSync gives every user a dashboard tailored to their role, backed by a relational MySQL database and secured with role-based access control.

## ✨ Features

- **Role-based access control**: each user type sees only the modules relevant to them
- **Patient management**: registration, profiles, and visit history
- **Appointment scheduling**: book, reschedule, and cancel appointments
- **Doctor and staff management**: departments, schedules, and assignments
- **Clinical records**: diagnoses, prescriptions, and notes
- **Billing and payments**: invoices and payment tracking
- **Secure authentication**: hashed passwords and session handling
- **Inline forms**: a clean UX that avoids modal popups

## 👥 User Roles

| Role | Typical access |
|------|----------------|
| Admin | Users, departments, system settings, reports |
| Doctor | Appointments, patient records, prescriptions |
| Nurse | Patient care notes, vitals |
| Receptionist | Registration, appointment booking |
| Pharmacist | Prescriptions, medicine inventory |
| Accountant | Billing, invoices, payments |
| Patient | Own appointments, records, bills |

> *Edit this table to match the roles in your build.*

## 🛠️ Tech Stack

| Layer | Technology |
|-------|------------|
| Backend | PHP |
| Database | MySQL |
| Frontend | HTML, CSS, JavaScript |
| Server | Apache via XAMPP |

## 🗂️ System Design

The project was designed before it was built, with documentation covering:

- System architecture diagram
- Entity-Relationship (ER) diagram
- UML diagrams (use case, class, sequence)
- Normalised relational database schema

See the [`/docs`](./docs) folder for the full design document.

## 🚀 Getting Started

### Prerequisites
- [XAMPP](https://www.apachefriends.org/) (Apache + MySQL + PHP)
- A web browser

### Installation

1. **Clone the repository** into your XAMPP `htdocs` folder
```bash
   cd C:/xampp/htdocs
   git clone https://github.com/<your-username>/medisync-hms.git
```

2. **Start Apache and MySQL** from the XAMPP Control Panel.

3. **Create the database**
   - Open [phpMyAdmin](http://localhost/phpmyadmin)
   - Create a database named `medisync_hms`
   - Import `database/medisync_hms.sql`

4. **Configure the connection** in `db.php`
```php
   $host = "localhost";
   $user = "root";
   $pass = "";
   $db   = "medisync_hms";
```

5. **Run the app** at `http://localhost/medisync-hms/`

## 🔐 Demo Credentials

| Role | Username | Password |
|------|----------|----------|
| Admin | `admin` | `admin123` |
| Doctor | `doctor` | `doctor123` |

> ⚠️ For local demo use only. Change all default credentials before any real deployment.

## 📁 Project Structure

```
medisync-hms/
├── admin/          # Admin dashboard
├── doctor/         # Doctor module
├── patient/        # Patient portal
├── includes/       # Shared helpers & layout
├── assets/         # CSS, JS, images
├── database/       # SQL schema & seed data
├── docs/           # Design documents & diagrams
├── db.php          # Database connection
└── index.php       # Login / entry point
```

## 📸 Screenshots

| Login | Admin Dashboard | Appointments |
|-------|-----------------|--------------|
| ![Login](docs/screenshots/login.png) | ![Admin](docs/screenshots/admin.png) | ![Appointments](docs/screenshots/appointments.png) |

## 🔮 Future Improvements

- Email/SMS appointment reminders
- Lab and radiology modules
- Reporting and analytics dashboards
- REST API for mobile integration
- Audit logging

## 👩‍💻 Author

**Sanduni Priyalakshi**
Software Engineering Undergraduate, CINEC Campus
[LinkedIn](https://linkedin.com/in/your-profile) · [GitHub](https://github.com/your-username)

## 📄 License

This project was created for academic purposes. Released under the [MIT License](LICENSE).
