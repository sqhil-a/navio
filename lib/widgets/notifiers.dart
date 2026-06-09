import 'package:flutter/material.dart';

// Navigation Bar
// Default to 1: center tab
ValueNotifier<int> selectedNavIndexNotifier = ValueNotifier(1);

// Onboarding
ValueNotifier<bool> completedOnboardingNotifier = ValueNotifier(false);
ValueNotifier<String> usernameNotifier = ValueNotifier("");
ValueNotifier<int> onboardingStepNotifier = ValueNotifier(0);

// Option Button
ValueNotifier<String?> selectedOptionButtonNotifier = ValueNotifier(null);

// Careers
final ValueNotifier<List<String>> careerListNotifier = ValueNotifier(
  [
    "Accounting",
    "Actuarial Science",
    "Addiction Counseling",
    "Advertising",
    "Aerospace Engineering",
    "Agriculture",
    "Anesthesiology",
    "Animation",
    "Anthropology",
    "Architecture",
    "Art Direction",
    "Art History",
    "Astronomy",
    "Astrophysics",
    "Athletic Training",
    "Audiology",
    "Automotive Engineering",
    "Aviation",
    "Biochemistry",
    "Biomedical Engineering",
    "Biology",
    "Biostatistics",
    "Biotechnology",
    "Brand Management",
    "Business Administration",
    "Cardiology",
    "Chemical Engineering",
    "Chemistry",
    "Child Psychology",
    "Chiropractic",
    "Civil Engineering",
    "Clinical Psychology",
    "Cloud Computing",
    "Cognitive Science",
    "Commercial Photography",
    "Communications",
    "Community Planning",
    "Computer Engineering",
    "Computer Science",
    "Construction Management",
    "Copywriting",
    "Cosmetology",
    "Criminal Justice",
    "Criminology",
    "Culinary Arts",
    "Cybersecurity",
    "Data Science",
    "Dentistry",
    "Dermatology",
    "Digital Marketing",
    "Early Childhood Education",
    "Economics",
    "Education",
    "Electrical Engineering",
    "Emergency Medicine",
    "Energy Engineering",
    "Entrepreneurship",
    "Environmental Engineering",
    "Environmental Law",
    "Environmental Science",
    "Epidemiology",
    "Event Planning",
    "Exercise Science",
    "Fashion Design",
    "Film Studies",
    "Finance",
    "Fire Science",
    "Food Science",
    "Forensic Science",
    "Game Design",
    "Genetics",
    "Geography",
    "Geophysics",
    "Graphic Design",
    "Health Administration",
    "Health Informatics",
    "History",
    "Hospitality Management",
    "Human Resources",
    "Illustration",
    "Industrial Design",
    "Industrial Engineering",
    "Information Security",
    "Information Technology",
    "Interior Design",
    "International Business",
    "International Relations",
    "Journalism",
    "Kinesiology",
    "Landscape Architecture",
    "Law",
    "Library Science",
    "Linguistics",
    "Logistics",
    "Machine Learning",
    "Management",
    "Marine Biology",
    "Marine Engineering",
    "Marketing",
    "Materials Science",
    "Mathematics",
    "Mechanical Engineering",
    "Media Studies",
    "Medicine",
    "Meteorology",
    "Microbiology",
    "Midwifery",
    "Military Science",
    "Music",
    "Music Production",
    "Neuroscience",
    "Nuclear Engineering",
    "Nursing",
    "Nutrition",
    "Occupational Therapy",
    "Oceanography",
    "Oncology",
    "Optometry",
    "Orthodontics",
    "Orthopedic Surgery",
    "Paleontology",
    "Paramedicine",
    "Pediatrics",
    "Petroleum Engineering",
    "Pharmacy",
    "Philosophy",
    "Physical Therapy",
    "Physics",
    "Political Science",
    "Product Management",
    "Psychology",
    "Public Administration",
    "Public Health",
    "Public Policy",
    "Public Relations",
    "Radiography",
    "Real Estate",
    "Robotics",
    "Social Work",
    "Sociology",
    "Software Engineering",
    "Special Education",
    "Speech Pathology",
    "Sports Management",
    "Statistics",
    "Supply Chain Management",
    "Surgery",
    "Taxation",
    "Theatre",
    "Tourism",
    "Translation",
    "UX Design",
    "Veterinary Medicine",
    "Visual Arts",
    "Web Development",
    "Wildlife Biology",
    "Zoology",
  ]..sort(),
);
ValueNotifier<String> careerNotifier = ValueNotifier("");
ValueNotifier<String> careerTitleNotifier = ValueNotifier("");

// Plan
ValueNotifier<bool> showPlanNotifier = ValueNotifier(false);
ValueNotifier<int> portfolioTabTapNotifier = ValueNotifier(0);
ValueNotifier<int> roadmapResourcesRequestNotifier = ValueNotifier(0);
ValueNotifier<int> roadmapResourceOpenedNotifier = ValueNotifier(0);

// Stage
ValueNotifier<String> stageNotifier = ValueNotifier("");

// AOI
final ValueNotifier<List<String>> aoiListNotifier = ValueNotifier(
  [
    // STEM
    "Technology",
    "Engineering",
    "Data & Analytics",
    "Artificial Intelligence",
    "Robotics",
    "Space & Astronomy",
    "Environment & Sustainability",
    "Science & Research",

    // Health & Life Sciences
    "Healthcare",
    "Mental Health",
    "Fitness & Wellness",
    "Biology & Life Sciences",

    // Business & Finance
    "Business",
    "Entrepreneurship",
    "Finance & Investing",
    "Marketing & Branding",
    "Sales",

    // Creative Fields
    "Design",
    "Art",
    "Music",
    "Film & Media",
    "Writing",
    "Content Creation",

    // Social / Society
    "Education",
    "Psychology",
    "Social Impact",
    "Politics",
    "Law",

    // Hands-on / Lifestyle
    "Building & Construction",
    "Mechanics & Vehicles",
    "Cooking & Food",
    "Travel & Exploration",

    // Tech niches
    "App Development",
    "Web Development",
    "Game Development",
    "Cybersecurity",
    "UI/UX Design",
  ]..sort(),
);
ValueNotifier<List<String>> selectedAoiNotifier = ValueNotifier([]);

// Style
final ValueNotifier<List<String>> styleListNotifier = ValueNotifier([
  "Creating",
  "Supporting",
  "Problem Solving",
  "Leading",
  "Researching",
  "Performing",
  "Mentoring",
  "Innovation",
]);

ValueNotifier<String?> selectedStyleNotifier = ValueNotifier(null);

// Simulator
/// Reset signal - increment to trigger
ValueNotifier<int> chatResetNotifier = ValueNotifier(0);
ValueNotifier<String> simulatorSeedPromptNotifier = ValueNotifier("");

// Auth
ValueNotifier<bool> showAuthPageNotifier = ValueNotifier(false);
