---
title: Upload doc solution
authors: [theremjx01]
tags: [architecture, engineering, feature-flags, best-practices]
description: An architecture assessment over a complex business scenario
featured: true
---

## Solution of automated upload in bulk

To address your query, I’ll outline a secure, deliverable, and manageable solution to transfer documents from an internal Shared Drive (NTFS) to an AWS S3 File Landing Zone, while generating a Control File with metadata for the Enterprise Document platform powered by Alfresco. This solution ensures data security for sensitive customer information, aligns with your automation needs using Jenkins and Docker, and keeps complexity manageable given your team’s engineering skills. Below is a step-by-step approach tailored to your requirements.

---

### Solution Overview

The goal is to:
- Transfer documents (e.g., PDFs, Excel, Word files) from an internal Shared Drive to an S3 bucket.
- Generate a Control File (JSON) with metadata such as category, tenant, business owner, and file path.
- Ensure security and compliance for sensitive customer data (e.g., loan-related documents).
- Automate the process via Jenkins using a Docker image.
- Handle potential cross-account AWS access securely and simply.

Here’s how we can achieve this:

---

### 1. Key Components

#### Docker Image
- **Purpose**: Ensures a consistent, isolated environment for the job.
- **Base**: Use a lightweight `node:alpine` image, as Node.js is familiar, supports JSON handling for the Control File, and integrates well with the AWS SDK.
- **Dependencies**:
  - AWS SDK for Node.js (for S3 uploads).
  - Optional SMB library (e.g., `smb2`) if the Shared Drive requires remote access via SMB protocol.

#### Node.js Script
- **Why Node.js?**: It simplifies metadata extraction and file handling in a single language, reducing complexity compared to combining Bash and JavaScript. It’s also widely understood, aligning with your engineering skills constraint.
- **Tasks**:
  1. **Access the Shared Drive**: Read files from the NTFS Shared Drive (mounted or via SMB).
  2. **List Documents**: Identify files to upload (e.g., based on file type or date).
  3. **Extract Metadata**: Derive metadata (e.g., tenant, business owner) from file properties, directory structure, or an external source.
  4. **Upload to S3**: Transfer files to the S3 File Landing Zone securely.
  5. **Generate Control File**: Create a JSON file with metadata and upload it to S3.
  6. **Clean Up**: Ensure no sensitive data remains post-execution.

#### Jenkins Automation
- **Execution**: Run the job in a Docker container via Jenkins for automation and isolation.
- **Parameters**: Pass configurations (e.g., Shared Drive path, S3 bucket name) via environment variables.

#### Security Measures
- **Authentication**: Use IAM roles for secure S3 access, avoiding hardcoded credentials.
- **Encryption**: Ensure data is encrypted in transit (HTTPS) and at rest (S3 SSE).
- **No Data Leakage**: Prevent sensitive data retention in Jenkins or Docker after the job.

---

### 2. Step-by-Step Workflow

#### Step 1: Docker Image Setup
- **Dockerfile Example**:
  ```dockerfile
  FROM node:alpine
  WORKDIR /app
  COPY package.json .
  RUN npm install aws-sdk
  COPY script.js .
  CMD ["node", "script.js"]
  ```
- Build and push this image to a container registry accessible by Jenkins (e.g., AWS ECR).

#### Step 2: Node.js Script
Here’s a high-level outline of the script (`script.js`):
```javascript
const AWS = require('aws-sdk');
const fs = require('fs').promises;
const path = require('path');

// Configure AWS SDK (credentials via IAM role)
const s3 = new AWS.S3();
const bucketName = process.env.S3_BUCKET;
const drivePath = process.env.SHARED_DRIVE_PATH;

async function processFiles() {
  const controlFileData = [];
  
  // List files from Shared Drive
  const files = await fs.readdir(drivePath);
  
  for (const file of files) {
    const filePath = path.join(drivePath, file);
    const fileKey = `documents/${file}`;

    // Extract metadata (customize based on your needs)
    const metadata = {
      filePath: fileKey,
      tenant: "tenant1", // Example: derive from directory or external source
      categoryDocId: "CAT123",
      businessOwner: "FinanceDept"
    };

    // Upload file to S3
    await s3.upload({
      Bucket: bucketName,
      Key: fileKey,
      Body: await fs.readFile(filePath)
    }).promise();

    controlFileData.push(metadata);
  }

  // Generate and upload Control File
  const controlFileKey = `control/control-${Date.now()}.json`;
  await s3.upload({
    Bucket: bucketName,
    Key: controlFileKey,
    Body: JSON.stringify(controlFileData, null, 2)
  }).promise();

  console.log("Upload complete!");
}

processFiles().catch(console.error);
```
- **Notes**:
  - Adjust `drivePath` access if using SMB instead of a mounted drive.
  - Customize metadata extraction logic based on your specific requirements.

#### Step 3: Jenkins Job Configuration
- **Pipeline Example**:
  ```groovy
  pipeline {
    agent {
      docker {
        image 'my-registry/nodejs-s3-uploader:latest'
        args '-v /path/to/shared/drive:/mnt/drive' // Mount Shared Drive if needed
      }
    }
    environment {
      S3_BUCKET = 'my-s3-landing-zone'
      SHARED_DRIVE_PATH = '/mnt/drive'
    }
    stages {
      stage('Upload Files') {
        steps {
          sh 'node script.js'
        }
      }
    }
  }
  ```
- **Cross-Account Access**:
  - Attach an IAM role to the Jenkins EC2 instance with permissions to write to the target S3 bucket.
  - Configure an S3 bucket policy in the Enterprise Document platform’s AWS account to allow access:
    ```json
    {
      "Effect": "Allow",
      "Principal": {"AWS": "arn:aws:iam::jenkins-account-id:role/jenkins-role"},
      "Action": ["s3:PutObject"],
      "Resource": "arn:aws:s3:::my-s3-landing-zone/*"
    }
    ```

#### Step 4: Security Implementation
- **IAM Role**: Ensure the Jenkins role has `s3:PutObject` permissions only for the target bucket.
- **Encryption**: Enable S3 Server-Side Encryption (e.g., SSE-S3) in the bucket policy.
- **No Residual Data**: The script processes files in memory and uploads directly to S3, avoiding local storage in Jenkins or Docker.
- **Network Access**: If the Shared Drive is intranet-only, ensure Jenkins runs in a network with access (e.g., via VPN or on-premises deployment).

---

### 3. Security and Compliance
- **Sensitive Data Protection**:
  - Files are transferred securely over HTTPS to S3.
  - No intermediate storage occurs in Jenkins or Docker.
- **Regulatory Compliance**:
  - Metadata in the Control File supports document retention and classification in Alfresco.
  - S3 access logs can be enabled for auditing.
- **Cross-Account Safety**:
  - The solution only requires S3 write access, not direct access to the Enterprise Document platform.

---

### 4. Handling Challenges
- **Network Access**:
  - **Issue**: Jenkins may not naturally access the intranet Shared Drive.
  - **Solution**: Mount the drive to the Jenkins host or use an SMB client in the script.
- **Metadata Complexity**:
  - **Issue**: Metadata like tenant or business owner may not be in file properties.
  - **Solution**: Use directory naming conventions or an external lookup (e.g., a CSV or API).
- **Error Handling**:
  - Add retries for S3 uploads and log failures for debugging.
- **Performance**:
  - For large file sets, process files in batches or use parallel uploads.

---

### 5. Why This Approach Works
- **Deliverability**: Uses standard tools (Node.js, Docker, Jenkins) and a single-language script.
- **Security**: Avoids running scripts on staff machines, ensures encryption, and prevents data leaks.
- **Simplicity**: Node.js handles both metadata and transfers, reducing complexity.
- **Cross-Account**: IAM roles and bucket policies handle permissions cleanly.

---

This solution fits your needs by securely transferring files from the Shared Drive to the S3 File Landing Zone, generating the required Control File, and integrating with the Enterprise Document platform’s bulk upload pattern. Let me know if you’d like to refine any part further!

## Other options - manual upload vs using script in staff's browser

Given your situation, where you need to upload approximately 500 documents as a one-time task, I understand you're leaning toward a simpler, manual approach instead of an automated solution. Since this is a one-off requirement and the script won’t need to be reused, a manual upload process could indeed be more practical. You’ve suggested uploading 30 documents per day, but you’re concerned about convincing your business stakeholders. I’ll help you frame a strong rationale for this manual approach and also briefly address the alternative of automating via the UI, which you’ve considered but noted requires script installation on user machines.

---

### Why the Manual Upload Approach Makes Sense

For a one-time task of uploading 500 documents, manually uploading them in batches of 30 per day is a straightforward, low-risk solution. Here’s how you can present this to your stakeholders:

#### 1. **Simplicity and Low Overhead**
   - **No Technical Setup**: Manual uploads don’t require developing, testing, or deploying a script. This means no need for engineering resources, allowing your team to focus on other priorities.
   - **Immediate Start**: Your team can begin uploading documents right away, without delays for script creation or troubleshooting. For a one-time task, this quick start is a big advantage.

#### 2. **Cost-Effectiveness**
   - **Minimal Resource Use**: Building and testing a script takes time and effort, which isn’t justified for a one-off task. Manual uploads achieve the same result with almost no additional cost.
   - **No Extra Tools**: There’s no need for software installations or infrastructure setup, keeping the process lean and simple.

#### 3. **Control and Accountability**
   - **Hands-On Verification**: Manually uploading documents lets your team check each upload immediately, catching issues like incorrect metadata or failed uploads right away.
   - **Clear Ownership**: Assigning team members to handle specific batches ensures accountability, which is key when dealing with sensitive customer data.

#### 4. **Manageable Workload**
   - **Reasonable Pace**: At 30 documents per day, uploading 500 documents takes about 17 days. This is a steady, manageable pace that won’t overload your team.
   - **Flexibility**: You can adjust the batch size or add more team members if you need to finish faster, making it adaptable to your needs.

#### 5. **Security and Compliance**
   - **Low Risk**: Uploading directly through the platform’s web app avoids intermediate storage or scripts handling sensitive data, reducing the chance of data leakage.
   - **Platform Alignment**: The platform is likely designed for manual uploads, so this method uses its intended workflow, ensuring security and compliance.

---

### How to Convince Your Stakeholders

To win over your stakeholders, focus on these key points and present them clearly:

- **Time and Resource Savings**: Highlight that the manual approach is faster to start and uses fewer resources than building a script. For a one-time task, simplicity wins over complexity.
- **Reduced Risk**: Emphasize that manual uploads avoid technical errors or security issues that could come with a script, especially important for sensitive customer data.
- **Practical Plan**: Share a clear outline, such as:
  - **Timeline**: 17 days to upload 500 documents at 30 per day.
  - **Responsibilities**: Assign specific team members to handle daily batches.
  - **Quality Checks**: Implement double-checking (e.g., confirming uploads and metadata) to ensure accuracy.
- **Cost vs. Benefit**: Point out that developing a script isn’t worth the effort for a one-off task when manual uploads get the job done effectively and at lower cost.

You could say something like:  
*"For this one-time upload of 500 documents, a manual process—uploading 30 documents per day over 17 days—is the simplest and safest option. It avoids the time and risk of building a script, lets us start immediately, and ensures full control over the process. We can assign team members to batches and double-check uploads, keeping everything accurate and secure with minimal effort."*

---

### Alternative: Automating via UI (Not Recommended)

You also considered automating the upload process via the UI with a script installed on user machines. While this could work (e.g., using a tool like Selenium), it’s not the best fit here:

- **Complexity**: UI automation scripts can be fragile—if the platform’s interface changes, the script breaks, requiring fixes that aren’t worth it for a one-time task.
- **Security Concerns**: Running scripts on user machines risks exposing sensitive customer data, and extra safeguards would be needed to prevent this.
- **Setup Effort**: Installing the script on each machine adds complexity and potential errors, outweighing any time savings for just 500 documents.

Since this is a one-off task, the manual approach is far simpler and safer than UI automation.

---

### Final Recommendation

For your one-time task of uploading 500 documents, the manual upload approach—30 documents per day over 17 days—is the most practical, secure, and cost-effective solution. It lets your team start right away, keeps the process under control, and avoids the hassle of scripting or automation.

To convince your stakeholders, present a clear plan with timelines, assigned roles, and quality checks. Stress that this method minimizes risk, saves resources, and fits the one-off nature of the task perfectly. If you need help refining your pitch or addressing specific objections, just let me know!

## Last point to check whether I missed anything else

Since you've settled on a simple manual solution for uploading 500 documents to a secure platform as a one-time task, it sounds like you’ve got a solid plan in place—uploading 30 documents per day to keep it manageable. However, I’ve thought through a few aspects to ensure you haven’t overlooked anything that could make the process smoother, safer, or more efficient. Here are some points you might want to consider:

### 1. Time and Effort
Manually uploading 500 documents at a rate of 30 per day will take about 17 days, which seems reasonable for a one-time task. However, depending on the size of the files or the platform’s interface, this could still be time-consuming or prone to interruptions.  
- **Suggestion**: Check if the platform offers a **bulk upload feature** or allows you to drag and drop multiple files at once. Even if you stick to 30 per day, batching them could save time and reduce repetitive clicks.

### 2. Data Security Details
You’ve mentioned the platform is designed for secure uploads, which is great since these documents contain sensitive customer information. Still, it’s worth double-checking a few specifics to avoid any risks.  
- **Suggestion**: Ensure all uploads happen over a **secure connection (HTTPS)** and that any local copies of documents are securely deleted after uploading. Also, verify the platform’s **access controls**—make sure only authorized team members can view or edit the uploaded files.

### 3. User Fatigue and Errors
Uploading 30 documents daily might feel straightforward, but over time, the repetition could lead to mistakes—like selecting the wrong file or entering incorrect metadata (e.g., customer names or dates).  
- **Suggestion**: Create a **simple checklist** for each upload batch (e.g., "File selected, metadata checked, upload confirmed"). Alternatively, have a teammate spot-check a few uploads periodically to catch errors early.

### 4. Documentation and Tracking
With 500 documents, it’s easy to lose track of what’s been uploaded, especially if something goes wrong (e.g., a file fails to upload unnoticed).  
- **Suggestion**: Keep a **basic log**—a spreadsheet or even a notebook—listing each uploaded document, the date, and any issues. This will help you monitor progress and troubleshoot if needed.

### 5. Future Considerations
You’ve noted this is a one-time task, and the script you considered wouldn’t be reusable, so sticking with manual uploads makes sense. However, it’s worth a quick thought about the future.  
- **Suggestion**: If there’s any chance of similar tasks popping up later, document your manual process (e.g., steps, time taken). This could make it easier next time, even without automation.

### Final Thoughts
Your manual solution is indeed simple and cost-effective, which fits the one-time nature of this task perfectly. The points above are just to polish it—ensuring it’s as efficient and secure as possible while minimizing hassle for your team. If the platform’s user-friendly and your team’s on board with the pace, you’ve likely covered the essentials. Let me know if you’d like me to dig deeper into any of these!