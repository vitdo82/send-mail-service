# AWS Route 53 Configuration for Sendmail

## 1. Configure DNS Records in Route 53

### A. MX (Mail Exchange) Record
This tells other mail servers where to deliver emails for your domain.
- Go to **Route 53 > Hosted Zones > Your Domain > Create Record**
- Choose **MX** and enter:
  ```
  Priority: 10
  Value: mail.yourdomain.com
  ```
- Ensure `mail.yourdomain.com` points to your **EC2 public IP or Elastic IP**.

### B. A (Address) Record
- Create an A record for `mail.yourdomain.com` pointing to your **EC2 instance's Elastic IP**.

### C. PTR (Reverse DNS) Record
- AWS doesn't allow you to set this in Route 53 directly.
- You must request AWS support to set up **Reverse DNS (PTR Record)** for your Elastic IP.

### D. SPF (Sender Policy Framework) Record
- Prevents spoofing and ensures email legitimacy.
- Add a **TXT** record in Route 53:
  ```
  v=spf1 ip4:<YOUR-EC2-PUBLIC-IP> -all
  ```
- Replace `<YOUR-EC2-PUBLIC-IP>` with your actual public IP.

### E. DKIM & DMARC Records
#### DKIM (DomainKeys Identified Mail)
- Improves email authentication.
- Add a **TXT** record:
  ```
  Name: default._domainkey.yourdomain.com
  Value: "v=DKIM1; k=rsa; p=<YOUR_DKIM_PUBLIC_KEY>"
  ```

#### DMARC (Domain-based Message Authentication, Reporting, and Conformance)
- Helps control handling of unauthenticated emails.
- Add a **TXT** record:
  ```
  Name: _dmarc.yourdomain.com
  Value: "v=DMARC1; p=none; rua=mailto:admin@yourdomain.com"
  ```
---

## 2. Open Required AWS Security Group Ports
In your **EC2 Security Group**, allow:
- **Port 25 (SMTP)** – Outbound (AWS restricts this; you may need to request removal).
- **Port 587 (SMTP with STARTTLS)** – Outbound.
- **Port 465 (SMTP with SSL)** – Outbound.
- **Port 110 (POP3)** and **143 (IMAP)** – If using a mail client.

---

## 3. AWS SES as an Alternative (Optional)
AWS limits **outbound SMTP (port 25)** on EC2.  
If your emails are being blocked, consider using **AWS SES (Simple Email Service)** as an external SMTP relay.

---

### Need More Help?
Let me know if you need assistance configuring Sendmail on AWS! 🚀
