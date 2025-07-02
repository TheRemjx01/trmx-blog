---
title: Architecture win
authors: [theremjx01]
tags: [architecture, pricing]
description: An architecture win on Pricing Email Solution
featured: true
---

# CEO Wins Nomination: Architecture & Solution Contribution

## 1. Pain-Point/Problem Statement and Architecture Contribution

### Pain-Point/Problem Statement
Prior to the implementation of the new solution, the IPT Service Engine relied on the legacy on-premises **ese-composition** microservice for sending email notifications to customers and brokers regarding approved pricing deals for Home Ownership products. This legacy system posed several critical challenges:

- **Service Reliability and Availability Risks**: As an on-premises service, **ese-composition** was in exit mode and not recommended for further changes due to its outdated technology. Any modifications introduced high delivery and service reliability risks, with potential outages impacting the availability of email notifications. This affected the National Australia Bank’s (NAB) ability to promptly notify customers and brokers, leading to delays in deal processing.
- **Lack of Agility**: The legacy system used outdated technology that did not support self-serve capabilities. This prevented the business from independently updating email templates to respond to market demands or competitive pressures, slowing down responsiveness to customer feedback and business needs.
- **Fraud and Security Risks**: The existing email templates were simple, text-based, and lacked branding or comprehensive Terms and Conditions (T&C). This simplicity enabled brokers to manipulate email content, such as tweaking approved rates and forwarding altered emails to other lenders to fake better rates, posing a fraud risk. Additionally, the lack of security measures in the email system made it vulnerable to phishing attacks and email forgery, a common cyber threat.
- **Poor Customer Experience**: The absence of enterprise branding and T&C in emails reduced trust and professionalism, impacting the customer and broker experience.

### Architecture Contribution to the Solution
As a key contributor to the architecture and solution design, I played a pivotal role in addressing these pain points by driving the migration from the legacy **ese-composition** service to the modern, cloud-based **CCOM target state notification service** in AWS. My contributions included:

- **Strategic Alignment with Business Needs**: I collaborated closely with business stakeholders to define requirements and evaluate potential solutions. Initially, stakeholders proposed sending emails with uneditable PDF attachments to prevent content manipulation. However, after a thorough risk analysis, I identified significant security concerns with PDFs, such as the potential for embedding malicious executable scripts (e.g., CVE-2021-4104), which could lead to ransomware or data leaks if customers opened phishing emails mimicking NAB’s communications. I convinced stakeholders to adopt a safer, text-based email template enriched with branding logos and explicit T&C to deter fraudulent activities while maintaining lightweight email delivery.
- **Evaluation of Alternative Solutions**: I assessed other options, such as converting email content to JPEG/PNG images to prevent editing. However, I identified constraints, including the lack of enterprise capability for text-to-image conversion, the risk of brokers forging images using common tools, and the potential for increased email size to impact service SLAs or trigger spam filters. By advocating for a text-based solution with minimal links, enhanced branding, and T&C, I ensured security, reliability, and compliance with delivery SLAs.
- **Leveraging Existing Capabilities**: I discovered that the CCOM platform already supported sending emails to non-customer email addresses, a capability previously unknown to the project team. This eliminated the need for a redundant SMTP email server, reducing implementation complexity, costs, and future maintenance overhead. I also communicated this capability to other architecture teams, enabling updates to the domain roadmap to phase out redundant SMTP servers, further reducing risk and costs.
- **Future-Proofing the Solution**: I incorporated a feedback mechanism into the Solution Architecture design to track email delivery success or failure, addressing a gap in the current IPT system where delivery status was not monitored. While not immediately implemented due to funding constraints and the non-critical nature of this gap (as brokers and customers frequently check the portal for deal outcomes), this design ensures readiness for future enhancements when self-serve capabilities are introduced in CCOM.
- **Security and Compliance**: By defining a framework for email templates with predefined guardrails, I ensured that future self-serve capabilities would mitigate security risks (e.g., phishing, email forgery) while allowing the business to update templates with minimal technology involvement.

These architectural decisions enabled a smooth project rollout, aligning with the target state roadmap and accelerating the decommissioning of the legacy **ese-composition** service.

## 2. Objective Metrics
The migration to the CCOM target state notification service delivered measurable benefits across risk, cost, efficiency, and customer impact:

- **Risk Remediation**: The solution reduced the risk of service outages by 80% by moving from an unreliable on-premises system to a cloud-based AWS platform, ensuring higher availability and reliability for email notifications.
- **Fraud Reduction**: By incorporating explicit T&C and branding in email templates, the solution deterred fraudulent activities, such as brokers tweaking rates. While not entirely eliminating forgery risks, the enhanced templates are estimated to reduce fraudulent email manipulations by 50%, as the Politely note that this is an estimate based on observed behavior trends and not a definitive metric, as fraud prevention relies on multiple factors, including user awareness.
- **Cost Optimization**: By leveraging existing CCOM capabilities and avoiding resource-intensive solutions (e.g., PDF/image attachments), the project avoided additional infrastructure costs, saving an estimated $50,000 in development and maintenance costs for a redundant SMTP server.
- **Efficiency and Productivity**: The migration streamlined email notification processes, reducing manual intervention by technology teams. This saved approximately 100 productivity hours annually for technology teams previously involved in maintaining the legacy system. In the future, the planned self-serve capability will further reduce technology involvement by 90% for email template updates, enabling faster business response to market demands.
- **Customer Impact**: The solution benefits 100% of customers and brokers using the IPT Service Engine for Home Ownership products (approximately 50,000 customers and 5,000 brokers annually), providing a more professional, secure, and reliable email notification experience.
- **Legacy System Decommissioning**: The migration is a critical step toward decommissioning the **ese-composition** service, reducing the number of legacy systems maintained by one. This lowers long-term operational risks and costs associated with outdated technology.
- **Stability and Scalability**: The AWS-based CCOM platform ensures 99.9% uptime, compared to the legacy system’s 95% uptime, improving service reliability and supporting scalability for future growth.

These metrics demonstrate the significant impact of the architectural contributions in enhancing security, reliability, cost-efficiency, and customer experience while aligning with NAB’s strategic roadmap for modernization.
