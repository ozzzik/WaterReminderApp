# GitHub Repository Setup Guide

This guide will help you set up your GitHub repository and connect it to your local Water Reminder project.

## 🚀 Step-by-Step Setup

### 1. Create GitHub Repository

1. **Go to GitHub.com** and sign in to your account
2. **Click the "+" icon** in the top right corner
3. **Select "New repository"**
4. **Fill in the repository details:**
   - **Repository name**: `WaterReminderApp`
   - **Description**: `A beautifully designed iOS app that helps you maintain proper hydration throughout the day with smart recurring notifications and intuitive water tracking.`
   - **Visibility**: Choose Public or Private
   - **Initialize with**: 
     - ✅ Add a README file
     - ✅ Add .gitignore (choose Swift)
     - ✅ Choose a license (MIT License)
5. **Click "Create repository"**

### 2. Connect Local Repository to GitHub

After creating the repository, GitHub will show you commands. Use these commands in your terminal:

```bash
# Add the remote origin (replace YOUR_USERNAME with your actual GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/WaterReminderApp.git

# Set the main branch as upstream
git branch -M main

# Push your local repository to GitHub
git push -u origin main
```

### 3. Update Documentation Links

After pushing to GitHub, update these files with your actual GitHub username:

#### README.md
- Replace `yourusername` with your actual GitHub username
- Update the clone URL in the installation section

#### CONTRIBUTING.md
- Replace `yourusername` with your actual GitHub username
- Update all GitHub links

#### CHANGELOG.md
- Replace `yourusername` with your actual GitHub username

### 4. Enable GitHub Pages (Optional)

To create a support URL for App Store Connect:

1. **Go to your repository on GitHub**
2. **Click "Settings"**
3. **Scroll down to "Pages" section**
4. **Under "Source", select "Deploy from a branch"**
5. **Choose "main" branch and "/docs" folder**
6. **Click "Save"**

Then create a support page:

```bash
# Create docs folder
mkdir docs

# Create support page
echo "# Water Reminder App Support

## Getting Help

### Common Issues
- **Notifications not working**: Check iOS Settings > Notifications > Water Reminder
- **App not launching**: Ensure iOS 17.0+ is installed
- **Reminders stopping**: Use 'Setup Daily Reminders' button to restore

### Contact Support
- **GitHub Issues**: [Report bugs here](https://github.com/YOUR_USERNAME/WaterReminderApp/issues)
- **Email**: your-email@domain.com

## Features
- Smart hydration tracking
- Recurring daily reminders
- Beautiful progress visualization
- Customizable goals and schedules

Stay hydrated! 💧" > docs/index.md

# Add and commit
git add docs/
git commit -m "Add support page for GitHub Pages"
git push
```

### 5. Repository Features to Enable

#### Issues
- **Go to Settings > Features**
- **Enable Issues** (should be enabled by default)
- **Enable Discussions** (optional, for community engagement)

#### Wiki
- **Go to Settings > Features**
- **Enable Wiki** for detailed documentation

#### Projects
- **Go to Settings > Features**
- **Enable Projects** for project management

### 6. Create GitHub Issues Template

Create `.github/ISSUE_TEMPLATE/bug_report.md`:

```markdown
---
name: Bug report
about: Create a report to help us improve
title: ''
labels: bug
assignees: ''

---

**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected behavior**
A clear and concise description of what you expected to happen.

**Screenshots**
If applicable, add screenshots to help explain your problem.

**Device Information:**
 - Device: [e.g. iPhone 15 Pro]
 - iOS Version: [e.g. 17.0]
 - App Version: [e.g. 1.0]

**Additional context**
Add any other context about the problem here.
```

### 7. Final Push

```bash
# Add all new files
git add .

# Commit changes
git commit -m "Complete GitHub repository setup with support page and templates"

# Push to GitHub
git push
```

## 🔗 Your Repository URLs

After setup, you'll have:

- **Repository**: `https://github.com/YOUR_USERNAME/WaterReminderApp`
- **Support URL**: `https://YOUR_USERNAME.github.io/WaterReminderApp/` (if GitHub Pages enabled)
- **Issues**: `https://github.com/YOUR_USERNAME/WaterReminderApp/issues`
- **Wiki**: `https://github.com/YOUR_USERNAME/WaterReminderApp/wiki`

## 📱 App Store URLs

### Support URL
Use this as your **Support URL** in App Store Connect:
```
https://github.com/YOUR_USERNAME/WaterReminderApp/issues
```

Or if you enabled GitHub Pages:
```
https://YOUR_USERNAME.github.io/WaterReminderApp/
```

### Privacy Policy URL
Use this as your **Privacy Policy URL** in App Store Connect:
```
https://YOUR_USERNAME.github.io/WaterReminderApp/privacy-policy.html
```

**Important:** You must enable GitHub Pages and use the `/docs` folder as the source for this to work.

## 🎉 Congratulations!

Your Water Reminder app now has a professional GitHub presence with:
- ✅ Comprehensive documentation
- ✅ Professional README with screenshots
- ✅ Contributing guidelines
- ✅ Issue templates
- ✅ Support page
- ✅ Proper licensing
- ✅ Change log tracking

Your app is ready for the App Store and open source collaboration! 🚀
