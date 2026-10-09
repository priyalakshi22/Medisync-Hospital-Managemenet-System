CREATE TABLE roles (
  role_id      INT AUTO_INCREMENT PRIMARY KEY,
  role_name    VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB;
 
INSERT INTO roles (role_name) VALUES
  ('Administrator'), ('Doctor'), ('Nurse'), ('Pharmacist'),
  ('Lab Technician'), ('Receptionist');
 
CREATE TABLE departments (
  department_id   INT AUTO_INCREMENT PRIMARY KEY,
  department_name VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;
 
INSERT INTO departments (department_name) VALUES
  ('Cardiology'), ('Pediatrics'), ('Orthopedics'), ('Gynecology'),
  ('General Medicine'), ('Pathology'), ('Pharmacy'),
  ('Administration'), ('Front Desk'), ('Emergency');
 
CREATE TABLE users (
  user_id         INT AUTO_INCREMENT PRIMARY KEY,
  full_name       VARCHAR(150) NOT NULL,
  email           VARCHAR(150) NOT NULL UNIQUE,
  password_hash   VARCHAR(255) NOT NULL,
  role_id         INT NOT NULL,
  department_id   INT NULL,
  phone           VARCHAR(30),
  staff_code      VARCHAR(20) UNIQUE,
  profile_photo   VARCHAR(255),
  status          ENUM('Active','Suspended','Pending Invite') NOT NULL DEFAULT 'Active',
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE RESTRICT,
  FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE SET NULL
) ENGINE=InnoDB;
 
CREATE TABLE user_module_access (
  access_id    INT AUTO_INCREMENT PRIMARY KEY,
  user_id      INT NOT NULL,
  module_name  VARCHAR(50) NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  UNIQUE KEY uq_user_module (user_id, module_name)
) ENGINE=InnoDB;
 
CREATE TABLE login_activity (
  activity_id   INT AUTO_INCREMENT PRIMARY KEY,
  user_id       INT NOT NULL,
  login_time    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  device        VARCHAR(150),
  location      VARCHAR(150),
  status        ENUM('Success','Blocked') NOT NULL DEFAULT 'Success',
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;
 
 
CREATE TABLE patients (
  patient_id     INT AUTO_INCREMENT PRIMARY KEY,
  full_name      VARCHAR(150) NOT NULL,
  age            INT,
  gender         ENUM('Male','Female','Other'),
  blood_type     VARCHAR(5),
  phone          VARCHAR(30),
  email          VARCHAR(150),
  address        VARCHAR(255),
  status         ENUM('Active','Inactive') NOT NULL DEFAULT 'Active',
  last_visit     DATE,
  registered_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
 
-- record_type added: the Medical Records page has separate "Diagnoses"
-- and "Treatment History" tabs. Both are visit records, so they share
-- this table; the app filters by record_type instead of using two
-- separate tables.
CREATE TABLE patient_medical_history (
  history_id   INT AUTO_INCREMENT PRIMARY KEY,
  patient_id   INT NOT NULL,
  record_type  ENUM('Diagnosis','Treatment') NOT NULL DEFAULT 'Diagnosis',
  visit_date   DATE NOT NULL,
  doctor_name  VARCHAR(150),
  diagnosis    VARCHAR(255),
  notes        TEXT,
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE
) ENGINE=InnoDB;
 
CREATE TABLE patient_documents (
  document_id   INT AUTO_INCREMENT PRIMARY KEY,
  patient_id    INT NOT NULL,
  file_name     VARCHAR(255) NOT NULL,
  file_type     VARCHAR(100),
  file_size     INT,
  file_path     VARCHAR(255),
  uploaded_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE
) ENGINE=InnoDB;
 
 
CREATE TABLE doctors (
  doctor_id       INT AUTO_INCREMENT PRIMARY KEY,
  user_id         INT NULL,
  full_name       VARCHAR(150) NOT NULL,
  specialization  VARCHAR(150),
  department_id   INT,
  phone           VARCHAR(30),
  email           VARCHAR(150),
  status          ENUM('Active','Leave') NOT NULL DEFAULT 'Active',
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
  FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE SET NULL
) ENGINE=InnoDB;
 
CREATE TABLE doctor_schedules (
  schedule_id   INT AUTO_INCREMENT PRIMARY KEY,
  doctor_id     INT NOT NULL,
  working_days  VARCHAR(50),
  start_time    TIME,
  end_time      TIME,
  room          VARCHAR(50),
  FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id) ON DELETE CASCADE
) ENGINE=InnoDB;
 
 
CREATE TABLE employees (
  employee_id   INT AUTO_INCREMENT PRIMARY KEY,
  user_id       INT NULL,
  full_name     VARCHAR(150) NOT NULL,
  role_title    VARCHAR(100),
  department_id INT,
  phone         VARCHAR(30),
  email         VARCHAR(150),
  date_joined   DATE,
  status        ENUM('Active','On Leave') NOT NULL DEFAULT 'Active',
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
  FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE SET NULL
) ENGINE=InnoDB;
 
-- New table: employees.department_id only ever holds the CURRENT
-- department. This table keeps every past assignment so the Staff
-- page's "Department Assignment" history view has something real to
-- read from. Whenever department_id changes on `employees`, insert a
-- new row here too.
CREATE TABLE department_assignments (
  assignment_id   INT AUTO_INCREMENT PRIMARY KEY,
  employee_id     INT NOT NULL,
  department_id   INT NOT NULL,
  effective_date  DATE NOT NULL,
  reason          VARCHAR(255),
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE,
  FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE CASCADE
) ENGINE=InnoDB;
 
CREATE TABLE attendance (
  attendance_id  INT AUTO_INCREMENT PRIMARY KEY,
  employee_id    INT NOT NULL,
  work_date      DATE NOT NULL,
  check_in       TIME,
  check_out      TIME,
  status         ENUM('Present','Late','Absent') NOT NULL,
  FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE,
  UNIQUE KEY uq_employee_date (employee_id, work_date)
) ENGINE=InnoDB;
 
CREATE TABLE leave_records (
  leave_id      INT AUTO_INCREMENT PRIMARY KEY,
  employee_id   INT NOT NULL,
  leave_type    ENUM('Annual Leave','Sick Leave','Casual Leave','Maternity / Paternity Leave','Unpaid Leave') NOT NULL,
  from_date     DATE NOT NULL,
  to_date       DATE NOT NULL,
  status        ENUM('Pending','Approved','Rejected') NOT NULL DEFAULT 'Pending',
  requested_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE
) ENGINE=InnoDB;
 
 
CREATE TABLE appointments (
  appointment_id    INT AUTO_INCREMENT PRIMARY KEY,
  patient_id        INT NOT NULL,
  doctor_id         INT NOT NULL,
  department_id     INT,
  appointment_type  VARCHAR(50),
  appointment_date  DATE NOT NULL,
  appointment_time  TIME NOT NULL,
  status            ENUM('Confirmed','Pending','Cancelled') NOT NULL DEFAULT 'Pending',
  notes             TEXT,
  created_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE,
  FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id) ON DELETE CASCADE,
  FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE SET NULL
) ENGINE=InnoDB;
 
 
CREATE TABLE invoices (
  invoice_id    INT AUTO_INCREMENT PRIMARY KEY,
  invoice_no    VARCHAR(20) NOT NULL UNIQUE,
  patient_id    INT NOT NULL,
  description   VARCHAR(255),
  amount        DECIMAL(12,2) NOT NULL DEFAULT 0,
  due_date      DATE,
  status        ENUM('Paid','Pending','Overdue') NOT NULL DEFAULT 'Pending',
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE
) ENGINE=InnoDB;
 
-- New table: the Billing and Appointments-checkout pages both build
-- invoices from multiple charge lines (Consultation, Laboratory,
-- Pharmacy, Admission, etc). `invoices.amount` stays as the cached
-- total (sum of these rows) so simple list views don't need a JOIN;
-- this table holds the actual breakdown.
CREATE TABLE invoice_items (
  item_id       INT AUTO_INCREMENT PRIMARY KEY,
  invoice_id    INT NOT NULL,
  category      ENUM('Consultation','Laboratory','Pharmacy','Admission','Other') NOT NULL DEFAULT 'Other',
  description   VARCHAR(255) NOT NULL,
  quantity      INT NOT NULL DEFAULT 1,
  unit_price    DECIMAL(12,2) NOT NULL DEFAULT 0,
  FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id) ON DELETE CASCADE
) ENGINE=InnoDB;
 
CREATE TABLE payments (
  payment_id    INT AUTO_INCREMENT PRIMARY KEY,
  invoice_id    INT NOT NULL,
  amount_paid   DECIMAL(12,2) NOT NULL,
  method        ENUM('Cash','Card','Bank','Insurance') NOT NULL,
  paid_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id) ON DELETE CASCADE
) ENGINE=InnoDB;
 
 
-- Lab pipeline note: this stays as 4 separate tables (request → sample
-- → result → report) rather than one status column, because each
-- stage is captured by a different role at a different time. The
-- front end's 4-step tracker should be DERIVED, not stored directly:
--   Requested      = row exists in lab_test_requests, no sample row
--   Sample Collected = row exists in lab_sample_collections
--   Result Entered  = row exists in lab_results
--   Reported        = row exists in lab_reports with status = 'Ready'
CREATE TABLE lab_test_requests (
  request_id    INT AUTO_INCREMENT PRIMARY KEY,
  patient_id    INT NOT NULL,
  doctor_id     INT,
  test_name     VARCHAR(150) NOT NULL,
  ward          VARCHAR(50),
  priority      ENUM('Routine','Urgent') NOT NULL DEFAULT 'Routine',
  status        ENUM('Pending','In Progress','Ready','Critical') NOT NULL DEFAULT 'Pending',
  requested_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  notes         TEXT,
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE,
  FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id) ON DELETE SET NULL
) ENGINE=InnoDB;
 
CREATE TABLE lab_sample_collections (
  sample_id      INT AUTO_INCREMENT PRIMARY KEY,
  request_id     INT NOT NULL,
  sample_type    VARCHAR(100),
  collected_by   VARCHAR(150),
  collected_at   DATETIME,
  status         ENUM('Pending Collection','Collected') NOT NULL DEFAULT 'Pending Collection',
  FOREIGN KEY (request_id) REFERENCES lab_test_requests(request_id) ON DELETE CASCADE
) ENGINE=InnoDB;
 
CREATE TABLE lab_results (
  result_id     INT AUTO_INCREMENT PRIMARY KEY,
  request_id    INT NOT NULL,
  result_value  TEXT,
  is_critical   TINYINT(1) NOT NULL DEFAULT 0,
  entered_by    VARCHAR(150),
  entered_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (request_id) REFERENCES lab_test_requests(request_id) ON DELETE CASCADE
) ENGINE=InnoDB;
 
CREATE TABLE lab_reports (
  report_id     INT AUTO_INCREMENT PRIMARY KEY,
  request_id    INT NOT NULL,
  generated_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status        ENUM('Processing','Ready') NOT NULL DEFAULT 'Processing',
  file_path     VARCHAR(255),
  FOREIGN KEY (request_id) REFERENCES lab_test_requests(request_id) ON DELETE CASCADE
) ENGINE=InnoDB;
 
CREATE TABLE medicines (
  medicine_id       INT AUTO_INCREMENT PRIMARY KEY,
  medicine_name     VARCHAR(150) NOT NULL,
  category          VARCHAR(100),
  form              VARCHAR(50),
  unit_price        DECIMAL(10,2) NOT NULL DEFAULT 0,
  quantity_in_stock INT NOT NULL DEFAULT 0,
  reorder_threshold INT NOT NULL DEFAULT 0
) ENGINE=InnoDB;
 
CREATE TABLE medicine_batches (
  batch_id       INT AUTO_INCREMENT PRIMARY KEY,
  medicine_id    INT NOT NULL,
  batch_no       VARCHAR(50) NOT NULL,
  quantity       INT NOT NULL DEFAULT 0,
  supplier       VARCHAR(150),
  received_date  DATE,
  expiry_date    DATE NOT NULL,
  FOREIGN KEY (medicine_id) REFERENCES medicines(medicine_id) ON DELETE CASCADE
) ENGINE=InnoDB;
 
CREATE TABLE prescriptions (
  prescription_id   INT AUTO_INCREMENT PRIMARY KEY,
  prescription_no   VARCHAR(20) NOT NULL UNIQUE,
  patient_id        INT NOT NULL,
  doctor_id         INT,
  appointment_id    INT NULL,
  status            ENUM('Pending','Processing','Dispensed') NOT NULL DEFAULT 'Pending',
  prescribed_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE,
  FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id) ON DELETE SET NULL,
  FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id) ON DELETE SET NULL
) ENGINE=InnoDB;
 
-- duration added: Medical Records captures dosage ("1 cap, 3x daily")
-- and duration ("7 days") as two separate form fields, not one string.
CREATE TABLE prescription_items (
  item_id          INT AUTO_INCREMENT PRIMARY KEY,
  prescription_id  INT NOT NULL,
  medicine_id      INT NOT NULL,
  dosage           VARCHAR(150),
  duration         VARCHAR(50),
  quantity         INT NOT NULL DEFAULT 1,
  FOREIGN KEY (prescription_id) REFERENCES prescriptions(prescription_id) ON DELETE CASCADE,
  FOREIGN KEY (medicine_id) REFERENCES medicines(medicine_id) ON DELETE RESTRICT
) ENGINE=InnoDB;
 
 
CREATE TABLE generated_reports (
  report_id      INT AUTO_INCREMENT PRIMARY KEY,
  category       ENUM('Patient','Appointment','Revenue','Pharmacy','Laboratory','Staff') NOT NULL,
  report_name    VARCHAR(200) NOT NULL,
  period_label   VARCHAR(50),
  status         ENUM('Processing','Ready') NOT NULL DEFAULT 'Processing',
  generated_by   INT NULL,
  generated_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  file_path      VARCHAR(255),
  FOREIGN KEY (generated_by) REFERENCES users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB;
 
 
CREATE TABLE feedback (
  feedback_id   INT AUTO_INCREMENT PRIMARY KEY,
  name          VARCHAR(150) NOT NULL,
  role          ENUM('Patient','Visitor','Staff Member') NOT NULL DEFAULT 'Patient',
  rating        TINYINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  department_id INT NULL,
  comments      TEXT,
  submitted_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE SET NULL
) ENGINE=InnoDB;
 
CREATE TABLE contact_messages (
  message_id    INT AUTO_INCREMENT PRIMARY KEY,
  name          VARCHAR(150) NOT NULL,
  email         VARCHAR(150) NOT NULL,
  phone         VARCHAR(30),
  subject       VARCHAR(150),
  message       TEXT NOT NULL,
  submitted_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
 
 
CREATE TABLE chat_messages (
  message_id   INT AUTO_INCREMENT PRIMARY KEY,
  user_id      INT NULL,
  sender       ENUM('user','bot') NOT NULL,
  message_text TEXT NOT NULL,
  sent_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB;
 
CREATE INDEX idx_appointments_date ON appointments(appointment_date);
CREATE INDEX idx_invoices_status ON invoices(status);
CREATE INDEX idx_lab_requests_status ON lab_test_requests(status);
CREATE INDEX idx_medicines_stock ON medicines(quantity_in_stock);
CREATE INDEX idx_patient_history_type ON patient_medical_history(patient_id, record_type);
 

INSERT INTO users (full_name, email, password_hash, role_id, department_id, phone, staff_code, status) VALUES
  ('Admin User', 'admin@medisync.lk', '$2y$10$replaceWithRealHash000000000000000000000000', 1, 8, '+94 77 123 4567', 'MS-0001', 'Active'),
  ('Dr. Fernando', 'fernando@medisync.lk', '$2y$10$replaceWithRealHash000000000000000000000001', 2, 1, '(212) 555-0147', 'MS-0002', 'Active'),
  ('Emma Wilson', 'emma@medisync.lk', '$2y$10$replaceWithRealHash000000000000000000000002', 3, 1, '(212) 555-0148', 'MS-0003', 'Active'),
  ('Mia Andron', 'mia@medisync.lk', '$2y$10$replaceWithRealHash000000000000000000000003', 4, 7, '(305) 555-0194', 'MS-0004', 'Active'),
  ('Noah Clark', 'noah@medisync.lk', '$2y$10$replaceWithRealHash000000000000000000000004', 5, 6, '(212) 555-0149', 'MS-0005', 'Pending Invite'),
  ('James White', 'james@medisync.lk', '$2y$10$replaceWithRealHash000000000000000000000005', 6, 9, '(415) 555-0168', 'MS-0006', 'Suspended');
 
INSERT INTO user_module_access (user_id, module_name) VALUES
  (1,'Dashboard'),(1,'Patients'),(1,'Doctors'),(1,'Billing'),(1,'Laboratory'),(1,'Pharmacy'),(1,'Staff'),(1,'Reports'),
  (2,'Dashboard'),(2,'Patients'),(2,'Laboratory'),
  (3,'Dashboard'),(3,'Patients'),
  (4,'Dashboard'),(4,'Pharmacy'),
  (5,'Dashboard'),(5,'Laboratory'),
  (6,'Dashboard'),(6,'Patients'),(6,'Billing');
 
INSERT INTO patients (full_name, age, gender, blood_type, phone, email, address, status, last_visit) VALUES
  ('John Smith', 35, 'Male', 'A', '(212) 555-0147', 'john@gmail.com', '', 'Active', '2025-10-25'),
  ('Emily John', 35, 'Male', 'A+', '(305) 555-0192', 'emily@gmail.com', '', 'Active', '2025-10-24'),
  ('Michael Brown', 35, 'Male', 'A', '(415) 555-0168', 'michale@gmail.com', '', 'Active', '2025-10-24'),
  ('Sarah Williams', 35, 'Male', 'B', '(713) 555-0119', 'sarah@gmail.com', '', 'Active', '2025-10-24'),
  ('James Wilson', 35, 'Male', 'B', '(415) 555-0168', 'james2@gmail.com', '', 'Inactive', '2025-10-23'),
  ('Sophia Taylor', 35, 'Male', 'A', '(702) 555-0186', 'sophia@gmail.com', '', 'Active', '2025-10-23');
 
INSERT INTO patient_medical_history (patient_id, record_type, visit_date, doctor_name, diagnosis, notes) VALUES
  (1, 'Diagnosis', '2025-10-25', 'Dr. Fernando', 'Hypertension follow-up', 'Blood pressure stable on current medication.'),
  (1, 'Treatment', '2025-10-25', 'Dr. Fernando', 'Continue Amlodipine 5mg', 'Reviewed dosage, no changes needed.'),
  (1, 'Diagnosis', '2025-07-12', 'Dr. Fernando', 'Routine cardiac checkup', 'ECG normal. Advised to reduce salt intake.');
 
INSERT INTO patient_documents (patient_id, file_name, file_type, file_size, uploaded_at) VALUES
  (1, 'ECG_Report_Jul2025.pdf', 'application/pdf', 214000, '2025-07-12 10:00:00');
 
INSERT INTO doctors (full_name, specialization, department_id, phone, email, status) VALUES
  ('Dr. Fernando', 'Interventional Cardiology', 1, '(212) 555-0147', 'fernando@medisync.lk', 'Active'),
  ('Dr. Silva', 'General Pediatrics', 2, '(305) 555-0192', 'silva@medisync.lk', 'Active'),
  ('Dr. Kumar', 'Neonatal Care', 2, '(415) 555-0168', 'kumar@medisync.lk', 'Leave'),
  ('Dr. David', 'Sports Medicine', 3, '(305) 555-0111', 'david@medisync.lk', 'Active'),
  ('Dr. Miller', 'Obstetrics & Gynecology', 4, '(713) 555-0119', 'miller@medisync.lk', 'Active');
 
INSERT INTO doctor_schedules (doctor_id, working_days, start_time, end_time, room) VALUES
  (1, 'Mon,Wed,Fri', '09:00:00', '13:00:00', 'Consulting Room 4'),
  (2, 'Tue,Thu', '14:00:00', '18:00:00', 'Consulting Room 2'),
  (3, 'Mon,Tue,Wed,Thu,Fri', '08:00:00', '12:00:00', 'Consulting Room 5'),
  (4, 'Mon,Wed,Fri', '10:00:00', '15:00:00', 'Consulting Room 6'),
  (5, 'Tue,Wed,Thu', '09:00:00', '12:30:00', 'Consulting Room 3');
 
INSERT INTO employees (full_name, role_title, department_id, phone, email, date_joined, status) VALUES
  ('Dr. Fernando', 'Doctor', 1, '(212) 555-0147', 'fernando@medisync.lk', '2020-03-01', 'Active'),
  ('Emma Wilson', 'Nurse', 1, '(212) 555-0148', 'emma@medisync.lk', '2021-06-15', 'Active'),
  ('Liam John', 'Nurse', 3, '(305) 555-0193', 'liam@medisync.lk', '2021-09-10', 'Active'),
  ('Noah Clark', 'Lab Technician', 6, '(212) 555-0149', 'noah@medisync.lk', '2022-01-20', 'Active'),
  ('Mia Andron', 'Pharmacist', 7, '(305) 555-0194', 'mia@medisync.lk', '2022-04-05', 'Active'),
  ('James White', 'Receptionist', 9, '(415) 555-0168', 'james@medisync.lk', '2019-11-11', 'On Leave'),
  ('Ava Taylor', 'Nurse', 3, '(415) 555-0169', 'ava@medisync.lk', '2023-02-14', 'On Leave');
 
-- One "Initial assignment" row per employee, matching their current department.
INSERT INTO department_assignments (employee_id, department_id, effective_date, reason) VALUES
  (1, 1, '2020-03-01', 'Initial assignment'),
  (2, 1, '2021-06-15', 'Initial assignment'),
  (3, 3, '2021-09-10', 'Initial assignment'),
  (4, 6, '2022-01-20', 'Initial assignment'),
  (5, 7, '2022-04-05', 'Initial assignment'),
  (6, 9, '2019-11-11', 'Initial assignment'),
  (7, 3, '2023-02-14', 'Initial assignment');
 
INSERT INTO attendance (employee_id, work_date, check_in, check_out, status) VALUES
  (1, '2026-09-01', '08:02:00', '16:15:00', 'Present'),
  (2, '2026-09-01', '07:58:00', '16:05:00', 'Present'),
  (3, '2026-09-01', '08:00:00', NULL, 'Present'),
  (4, '2026-09-01', NULL, NULL, 'Absent'),
  (5, '2026-09-01', '08:10:00', '16:20:00', 'Present'),
  (6, '2026-09-01', NULL, NULL, 'Absent'),
  (7, '2026-09-01', NULL, NULL, 'Absent');
 
INSERT INTO leave_records (employee_id, leave_type, from_date, to_date, status) VALUES
  (6, 'Sick Leave', '2026-08-30', '2026-09-02', 'Approved'),
  (7, 'Annual Leave', '2026-08-28', '2026-09-04', 'Approved'),
  (4, 'Casual Leave', '2026-09-01', '2026-09-01', 'Approved'),
  (2, 'Annual Leave', '2026-09-10', '2026-09-14', 'Pending');
 
INSERT INTO appointments (patient_id, doctor_id, department_id, appointment_type, appointment_date, appointment_time, status) VALUES
  (2, 1, 1, 'Follow-up', '2025-10-31', '08:00:00', 'Confirmed'),
  (5, 4, 3, 'New Consultation', '2025-10-31', '08:30:00', 'Confirmed'),
  (6, 5, 4, 'Routine Checkup', '2025-10-31', '09:00:00', 'Confirmed'),
  (3, 1, 1, 'Follow-up', '2025-10-31', '20:00:00', 'Pending');
 
INSERT INTO invoices (invoice_no, patient_id, description, amount, due_date, status) VALUES
  ('INV-3021', 1, 'Ward admission — 3 nights', 84500.00, '2026-08-28', 'Pending'),
  ('INV-3020', 2, 'Consultation — General Medicine', 3200.00, '2026-08-26', 'Paid'),
  ('INV-3019', 3, 'Chest X-Ray & Lab Panel', 12750.00, '2026-08-18', 'Overdue'),
  ('INV-3018', 4, 'Ward admission — 2 nights', 61300.00, '2026-08-22', 'Paid'),
  ('INV-3017', 6, 'Consultation — Orthopedics', 4000.00, '2026-08-30', 'Pending');
 
-- Line-item breakdown for each invoice above. amount on `invoices`
-- should equal SUM(quantity * unit_price) from these rows per invoice.
INSERT INTO invoice_items (invoice_id, category, description, quantity, unit_price) VALUES
  (1, 'Admission', 'Ward admission — 3 nights', 3, 28166.67),
  (2, 'Consultation', 'Consultation — General Medicine', 1, 3200.00),
  (3, 'Laboratory', 'Chest X-Ray', 1, 6500.00),
  (3, 'Laboratory', 'Full Blood Count panel', 1, 6250.00),
  (4, 'Admission', 'Ward admission — 2 nights', 2, 30650.00),
  (5, 'Consultation', 'Consultation — Orthopedics', 1, 4000.00);
 
INSERT INTO payments (invoice_id, amount_paid, method) VALUES
  (2, 3200.00, 'Card'),
  (4, 61300.00, 'Insurance');
 
INSERT INTO lab_test_requests (patient_id, doctor_id, test_name, ward, status) VALUES
  (1, 1, 'Full Blood Count', 'Ward 3B', 'Pending'),
  (2, 2, 'Liver Function Test', 'OPD', 'In Progress'),
  (3, 1, 'Chest X-Ray', 'Ward 1A', 'Ready'),
  (4, 4, 'Blood Glucose (Fasting)', 'Ward 2C', 'Critical'),
  (6, 5, 'Urine Culture', 'OPD', 'In Progress');
 
INSERT INTO lab_sample_collections (request_id, sample_type, collected_by, status) VALUES
  (1, 'Blood', NULL, 'Pending Collection'),
  (2, 'Blood', 'Noah Clark', 'Collected'),
  (4, 'Blood', 'Noah Clark', 'Collected');
 
INSERT INTO lab_results (request_id, result_value, is_critical, entered_by) VALUES
  (3, 'No acute abnormality on chest X-ray.', 0, 'Noah Clark'),
  (4, 'Fasting glucose 210 mg/dL — above critical threshold.', 1, 'Noah Clark');
 
INSERT INTO lab_reports (request_id, status, file_path) VALUES
  (3, 'Ready', '/reports/lab/req3.pdf');
 
INSERT INTO medicines (medicine_name, category, form, unit_price, quantity_in_stock, reorder_threshold) VALUES
  ('Paracetamol 500mg', 'Analgesic', 'Tablet', 5.50, 860, 200),
  ('Amoxicillin 500mg', 'Antibiotic', 'Capsule', 18.00, 48, 100),
  ('Insulin (Rapid-acting)', 'Cardiac', 'Injection', 420.00, 0, 30),
  ('Salbutamol Inhaler', 'Respiratory', 'Inhaler', 650.00, 15, 40),
  ('Normal Saline 0.9%', 'IV Fluids', 'IV Bag', 220.00, 0, 50),
  ('Paracetamol IV', 'Analgesic', 'Injection', 340.00, 120, 60),
  ('Atorvastatin 20mg', 'Cardiac', 'Tablet', 22.00, 310, 100);
 
INSERT INTO medicine_batches (medicine_id, batch_no, quantity, supplier, received_date, expiry_date) VALUES
  (6, 'PC-2291', 120, 'Ceylon Pharma Distributors', '2026-06-01', '2026-09-12'),
  (2, 'AM-1187', 48, 'Ceylon Pharma Distributors', '2026-05-15', '2026-09-04'),
  (5, 'NS-0087', 0, 'MedSupply Lanka', '2026-03-01', '2026-08-20'),
  (3, 'IN-3345', 0, 'MedSupply Lanka', '2026-02-10', '2026-08-05'),
  (4, 'SB-2210', 15, 'Ceylon Pharma Distributors', '2026-06-20', '2026-12-18'),
  (7, 'AT-5502', 310, 'MedSupply Lanka', '2026-01-05', '2027-03-01');
 
INSERT INTO prescriptions (prescription_no, patient_id, doctor_id, status) VALUES
  ('RX-4021', 1, 1, 'Pending'),
  ('RX-4020', 2, 2, 'Processing'),
  ('RX-4019', 3, 2, 'Dispensed'),
  ('RX-4018', 4, 1, 'Pending');
 
INSERT INTO prescription_items (prescription_id, medicine_id, dosage, duration, quantity) VALUES
  (1, 2, '1 cap, 3x daily', '7 days', 21),
  (1, 1, '1 tab, as needed for fever', NULL, 10),
  (2, 4, '2 puffs, 2x daily', NULL, 1),
  (3, 7, '1 tab, nightly', '30 days', 30),
  (3, 5, '1 bag, IV infusion', NULL, 1),
  (4, 3, '10 units before meals', NULL, 1);
 
INSERT INTO feedback (name, role, rating, department_id, comments, submitted_at) VALUES
  ('R. Fernando', 'Patient', 5, 1, 'Dr. Fernando and the nursing staff were excellent — very attentive and explained everything clearly.', '2026-08-30 10:00:00'),
  ('S. Wickramasinghe', 'Patient', 4, 7, 'Quick service at the pharmacy counter, though the waiting area could use more seating.', '2026-08-28 14:20:00'),
  ('M. Jayasuriya', 'Visitor', 5, 10, 'Very impressed by how fast the emergency team responded. Thank you for the care shown to my father.', '2026-08-25 09:15:00'),
  ('A. Silva', 'Patient', 3, 6, 'Lab results took a bit longer than expected, but the staff were friendly and kept me updated.', '2026-08-22 16:40:00');
 
INSERT INTO contact_messages (name, email, phone, subject, message) VALUES
  ('K. Perera', 'kperera@example.com', '+94 77 555 1122', 'Appointment request', 'I would like to schedule a cardiology consultation next week.');
 
SET FOREIGN_KEY_CHECKS = 1;
 