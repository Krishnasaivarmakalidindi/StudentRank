# StudentRank - Architecture & Implementation Plan

## Overview
StudentRank is a premium academic reputation platform for college students. It tracks verified academic contributions, not exam marks. The app combines the professionalism of LinkedIn, the engagement mechanics of Duolingo, and the trust framework of GitHub.

## Design Philosophy
- **Sophisticated Monochrome Design**: Professional, clean, and academic
- **Light Mode**: Pure white backgrounds (#FFFFFF) with soft blue-grey tones
- **Dark Mode**: Deep blue-charcoal (#0F1419) with elevated surfaces
- **Accent Color**: Deep academic blue (#1E40AF) for trust and authority
- **Typography**: Inter font family for modern, readable text
- **Spacing**: Generous whitespace, thumb-first UX
- **Components**: Modular, reusable widgets

## Technical Stack
- **Framework**: Flutter 3.6+ (cross-platform: Android, iOS, Web)
- **Navigation**: go_router for declarative routing
- **State Management**: Provider for app-wide state
- **Backend**: Firebase (Cloud Firestore for database)
- **Fonts**: Google Fonts (Inter)

## Data Models

### 1. User Model (`lib/models/user.dart`)
- id (String)
- name (String)
- email (String)
- collegeName (String)
- isVerified (bool)
- profileImageUrl (String?)
- bio (String?)
- reputationScore (int)
- collegeRank (int)
- level (int)
- joinedDate (DateTime)
- subjects (List<String>)
- badges (List<Badge>)
- createdAt (DateTime)
- updatedAt (DateTime)

### 2. Resource Model (`lib/models/resource.dart`)
- id (String)
- title (String)
- description (String)
- type (ResourceType: notes, quiz, question, improvement)
- subject (String)
- topic (String?)
- authorId (String)
- authorName (String)
- qualityRating (double)
- reputationImpact (int)
- viewCount (int)
- downloadCount (int)
- improveCount (int)
- fileUrl (String?)
- thumbnailUrl (String?)
- isPlagiarized (bool)
- createdAt (DateTime)
- updatedAt (DateTime)

### 3. StudyGroup Model (`lib/models/study_group.dart`)
- id (String)
- name (String)
- description (String)
- subject (String)
- college (String)
- memberCount (int)
- isPrivate (bool)
- adminId (String)
- members (List<String>)
- resourceIds (List<String>)
- createdAt (DateTime)
- updatedAt (DateTime)

### 4. Badge Model (`lib/models/badge.dart`)
- id (String)
- name (String)
- description (String)
- iconName (String)
- earnedDate (DateTime)
- subject (String?)

### 5. Activity Model (`lib/models/activity.dart`)
- id (String)
- userId (String)
- type (ActivityType: upload, improve, answer, achievement)
- title (String)
- description (String)
- reputationChange (int)
- resourceId (String?)
- createdAt (DateTime)

## Service Classes (Firebase-Powered)

All services now use Cloud Firestore for real-time data storage and synchronization.

### 1. UserService (`lib/services/user_service.dart`)
- getCurrentUser() → User?
- getUserById(String userId) → User?
- createUser(User user)
- updateProfile(User user)
- updateReputationScore(String userId, int change)
- addBadge(String userId, Badge badge)
- getAllUsers() → List<User>
- getTopContributors({String? subject, int limit}) → List<User>
- getUserStream(String userId) → Stream<User?>

### 2. ResourceService (`lib/services/resource_service.dart`)
- getAllResources() → List<Resource>
- getResourcesBySubject(String subject) → List<Resource>
- getTrendingResources({int limit}) → List<Resource>
- uploadResource(Resource resource) → String (returns doc ID)
- improveResource(String resourceId, String improvements)
- searchResources(String query) → List<Resource>
- getResourceById(String id) → Resource?
- incrementViewCount(String resourceId)
- incrementDownloadCount(String resourceId)
- getResourcesStream({int limit}) → Stream<List<Resource>>
- getResourcesByAuthor(String authorId, {int limit}) → List<Resource>

### 3. StudyGroupService (`lib/services/study_group_service.dart`)
- getAllGroups() → List<StudyGroup>
- getMyGroups(String userId) → List<StudyGroup>
- createGroup(StudyGroup group) → String (returns doc ID)
- joinGroup(String groupId, String userId)
- leaveGroup(String groupId, String userId)
- getGroupById(String id) → StudyGroup?
- getGroupsBySubject(String subject) → List<StudyGroup>
- getGroupsStream({int limit}) → Stream<List<StudyGroup>>
- getGroupStream(String groupId) → Stream<StudyGroup?>

### 4. ActivityService (`lib/services/activity_service.dart`)
- getRecentActivities(String userId, {int limit}) → List<Activity>
- getFeedActivities({int limit}) → List<Activity>
- addActivity(Activity activity) → String (returns doc ID)
- getActivitiesStream(String userId, {int limit}) → Stream<List<Activity>>
- getFeedStream({int limit}) → Stream<List<Activity>>

## Firebase Configuration

### Collections
- `users` - User profiles and account data
- `resources` - Academic content (notes, quizzes, questions)
- `activities` - User activity feed items
- `study_groups` - Study group information

### Security Rules (`firestore.rules`)
- **Users**: Authenticated users can read all profiles, but only update their own
- **Resources**: Authenticated users can read all, create with proper authorId, and delete only their own
- **Activities**: Authenticated users can read all, but only create/update their own activities
- **Study Groups**: Authenticated users can read all, create with proper adminId, and update (for joining/leaving)

### Indexes (`firestore.indexes.json`)
Composite indexes configured for:
- Users by subjects + reputation score (for leaderboards)
- Resources by subject + createdAt (for subject filtering)
- Resources by viewCount + qualityRating (for trending)
- Resources by authorId + createdAt (for user profiles)
- Activities by userId + createdAt (for activity feeds)
- Study groups by members + updatedAt (for "my groups")
- Study groups by subject + memberCount (for popular groups by subject)

## App Structure

### Authentication & Onboarding
1. **Splash Screen** (`/splash`)
2. **Welcome Screen** (`/welcome`)
3. **College Verification** (`/verification`)
4. **Profile Setup** (`/setup/profile`)
5. **Subject Selection** (`/setup/subjects`)
6. **Guided Tour** (`/tour`)

### Main App (Bottom Navigation)
1. **Home** (`/home`)
   - Greeting header with verified badge
   - Reputation snapshot card
   - Quick actions (4 buttons)
   - Smart activity feed
   - Daily contribution CTA

2. **Explore** (`/explore`)
   - Subject filter chips
   - Search bar
   - Top contributors carousel
   - Trending resources grid
   - Subject leaderboards

3. **Contribute** (`/contribute`)
   - Upload notes
   - Improve content
   - Answer questions
   - Create quiz

4. **Groups** (`/groups`)
   - My groups list
   - Browse groups
   - Group detail view
   - Group feed

5. **Profile** (`/profile`)
   - Profile header
   - Reputation & rank display
   - Skill badges
   - Contribution timeline
   - Tabs: Contributions, Badges, Activity, Reviews

### Additional Screens
- **Resource Detail** (`/resource/:id`)
- **Group Detail** (`/group/:id`)
- **User Profile** (`/user/:id`)
- **Settings** (`/settings`)
- **Search Results** (`/search`)
- **Upload Flow** (`/upload`)
- **Leaderboard** (`/leaderboard/:subject`)

## Reusable Components

### Cards
- `ReputationCard` - Shows score, rank, progress
- `ResourceCard` - Displays resource preview
- `ActivityCard` - Shows activity feed item
- `GroupCard` - Group preview
- `BadgeCard` - Badge display
- `ContributorCard` - Top contributor preview

### Buttons
- `QuickActionButton` - Icon + label for home
- `PrimaryButton` - Main CTA button
- `OutlinedButton` - Secondary actions
- `ChipButton` - Filter/tag chips

### Headers
- `ProfileHeader` - User info with verified badge
- `SectionHeader` - Section titles with actions
- `SearchBar` - Custom search input

### Lists
- `ResourceList` - Scrollable resource items
- `ActivityFeed` - Activity timeline
- `LeaderboardList` - Ranked user list

### Empty States
- `EmptyState` - Illustrations + messages

### Badges
- `VerifiedBadge` - College verification indicator
- `SkillBadge` - Earned badge display
- `LevelBadge` - User level indicator

## Implementation Steps

### Phase 1: Foundation (Core Setup)
1. ✅ Update theme with academic color palette
2. ✅ Create all data models with sample data
3. ✅ Implement service classes with local storage
4. ✅ Set up navigation structure with all routes

### Phase 2: Authentication & Onboarding
5. ✅ Build splash screen with logo animation
6. ✅ Create welcome screen with value proposition
7. ✅ Implement college verification flow
8. ✅ Build profile setup screen
9. ✅ Create subject selection interface
10. ✅ Add guided tour overlay

### Phase 3: Core Features
11. ✅ Build home screen with all sections
12. ✅ Create explore screen with filters
13. ✅ Implement contribute flow
14. ✅ Build study groups interface
15. ✅ Create profile screen with tabs

### Phase 4: Detail Screens
16. ✅ Build resource detail view
17. ✅ Create group detail screen
18. ✅ Implement settings screen
19. ✅ Add search functionality
20. ✅ Build leaderboard views

### Phase 5: Polish & Testing
21. ✅ Add animations and transitions
22. ✅ Implement error handling
23. ✅ Test all flows
24. ✅ Fix compilation errors
25. ✅ Final QA

## Key Features

### Reputation System
- Points for uploads, improvements, answers
- Quality-weighted scoring
- Subject-specific rankings
- Level progression with badges

### Content Quality
- AI-assisted tagging
- Community ratings
- Improvement tracking
- Plagiarism detection indicators

### Social Features
- Study groups
- Activity feeds
- Top contributors
- Anonymous feedback

### Gamification
- Daily streaks
- Achievement badges
- Leaderboards
- Progress visualization

## Future Enhancements
- ✅ Firebase Cloud Firestore integration
- Firebase Authentication for secure login
- Real-time collaboration features
- Push notifications for activity updates
- AI-powered content recommendations
- College admin dashboards
- Export academic profiles to PDF
- LinkedIn profile integration
- WhatsApp group sync
