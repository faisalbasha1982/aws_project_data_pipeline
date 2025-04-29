# 📢 Event Announcement System using AWS

This project demonstrates an **Event Announcement System** built using AWS services like **S3**, **Lambda**, **API Gateway**, and **SNS**.

---

## 🛠️ System Overview

The system allows users to:
- ✅ View a list of events
- ✏️ Create new events
- 📧 Subscribe to email notifications for new events

---

## 📦 AWS Services Used

| Service       | Purpose                                               |
|---------------|--------------------------------------------------------|
| **S3**        | Static website hosting (HTML, CSS, and `events.json`) |
| **API Gateway** | REST API endpoints (`/new-event`, `/subscribers`)   |
| **Lambda**    | Backend logic for event creation and email subscription |
| **SNS**       | Send email notifications to subscribed users          |

---

## 🔧 Steps to Build the Project

### 1. S3 Static Website
- Upload your static files: `index.html`, `style.css`, `script.js`, and `events.json`
- Enable **Static Website Hosting** on your S3 bucket
- Make the bucket **public**, or use **CloudFront + signed URLs** for access control

---

### 2. API Gateway Setup
Create two **POST** endpoints:

- `/new-event` → Triggers **Event Registration Lambda**
- `/subscribers` → Triggers **Subscription Lambda**

---

### 3. Lambda Functions

#### 📨 Subscription Lambda
- Adds the user’s email to the SNS topic subscription list

#### 🗂️ Event Registration Lambda
- Reads form data from the API request
- Appends the new event to `events.json` in S3
- Publishes an SNS notification about the new event

---

### 4. SNS Topic
- Create an **SNS topic** for event notifications
- Allow both Lambda functions to **publish to the topic**
- Subscribers must **confirm** their email to start receiving updates

---

## ✅ Final Outcome
A fully functional serverless system for publishing and subscribing to event notifications using AWS-native tools.

---

> Feel free to customize or expand the system to include authentication (e.g., using Amazon Cognito) or integrate with additional notification channels like SMS.
