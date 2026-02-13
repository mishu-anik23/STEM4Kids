require('dotenv').config();
const { sequelize } = require('../src/config/database');
const { Island, Topic, Level } = require('../src/models');

const physicsIslandData = {
  code: 'island_w1_physics',
  worldId: 1,
  name: 'Physics Island',
  description: 'Explore the wonders of light, shadows, and forces!',
  topicCategory: 'physics',
  orderIndex: 1,
  iconUrl: 'assets/images/islands/physics_island.png',
  unlockRequirements: null,
  isActive: true
};

const physicsTopics = [
  {
    code: 'topic_p1_light_sources',
    name: 'Light Sources',
    description: 'Identify and use natural vs artificial light sources.',
    learningObjectives: [
      'Identify different types of light sources (natural and artificial)',
      'Distinguish between objects that make light vs reflect light',
      'Understand appropriate light sources for different situations'
    ],
    orderIndex: 1,
    iconUrl: 'assets/images/topics/light_sources.png',
    difficultyLevel: 'beginner',
    levelCount: 10
  },
  {
    code: 'topic_p2_day_night',
    name: 'Day and Night',
    description: 'Recognize day vs night patterns and activities.',
    learningObjectives: [
      'Understand the difference between day and night',
      'Match activities and animals to appropriate times',
      'Recognize daily routines and time patterns'
    ],
    orderIndex: 2,
    iconUrl: 'assets/images/topics/day_night.png',
    difficultyLevel: 'beginner',
    levelCount: 10
  },
  {
    code: 'topic_p3_shadows',
    name: 'Shadows',
    description: 'Understand that shadows are formed when light is blocked.',
    learningObjectives: [
      'Understand that shadows are made when light is blocked',
      'Predict shadow size and position based on light location',
      'Match objects to their shadow shapes'
    ],
    orderIndex: 3,
    iconUrl: 'assets/images/topics/shadows.png',
    difficultyLevel: 'beginner',
    levelCount: 10
  },
  {
    code: 'topic_p4_hot_cold',
    name: 'Hot and Cold',
    description: 'Recognize hot vs cold objects and make safe choices.',
    learningObjectives: [
      'Identify hot and cold objects',
      'Understand safety around hot objects',
      'Recognize ways to warm or cool things'
    ],
    orderIndex: 4,
    iconUrl: 'assets/images/topics/hot_cold.png',
    difficultyLevel: 'beginner',
    levelCount: 10
  },
  {
    code: 'topic_p5_push_pull',
    name: 'Push and Pull',
    description: 'Understand push vs pull actions and basic forces.',
    learningObjectives: [
      'Identify push vs pull actions',
      'Understand how forces make objects move',
      'Apply push/pull concepts to solve simple problems'
    ],
    orderIndex: 5,
    iconUrl: 'assets/images/topics/push_pull.png',
    difficultyLevel: 'beginner',
    levelCount: 10
  }
];

const levelsData = {
  topic_p1_light_sources: [
    {
      levelNumber: 1,
      name: 'Tap the lights',
      description: 'Tap all objects that give light (Sun, lamp, torch) in a scene.',
      challengeType: 'tap_objects',
      difficultyLevel: 'easy',
      estimatedDurationMinutes: 2,
      storyText: 'Welcome to Light Land! Can you find all the things that make light?',
      lessonContent: 'Some things make their own light, like the Sun, lamps, and torches. Let\'s find them!',
      challengeConfig: {
        targetObjects: ['sun', 'lamp', 'torch', 'candle', 'lightbulb'],
        distractorObjects: ['chair', 'book', 'table', 'ball'],
        minCorrect: 3
      },
      hints: [
        'Look for things that glow or shine',
        'The Sun is a natural light source',
        'Lamps and torches need electricity or batteries'
      ],
      successMessage: 'Great job! You found all the light sources!',
      xpReward: 10,
      coinsReward: 5
    },
    {
      levelNumber: 2,
      name: 'Sort it',
      description: 'Drag "light source" vs "not a light source" into two baskets.',
      challengeType: 'sort_items',
      difficultyLevel: 'easy',
      estimatedDurationMinutes: 3,
      storyText: 'Luna needs help sorting objects. Which ones make light?',
      lessonContent: 'Light sources make their own light. Other objects only reflect light from light sources.',
      challengeConfig: {
        lightSources: ['sun', 'lamp', 'torch', 'candle', 'firefly', 'lightbulb'],
        notLightSources: ['moon', 'mirror', 'window', 'book', 'table', 'water'],
        categories: ['Makes Light', 'Does Not Make Light']
      },
      hints: [
        'The moon reflects light from the Sun',
        'Mirrors show light but don\'t make it',
        'Fire and electricity can make light'
      ],
      successMessage: 'Perfect sorting! You understand light sources!',
      xpReward: 12,
      coinsReward: 6
    },
    {
      levelNumber: 3,
      name: 'Find the path',
      description: 'Move a character only across tiles with light sources to reach the goal.',
      challengeType: 'path_finding',
      difficultyLevel: 'easy',
      estimatedDurationMinutes: 3,
      storyText: 'Help Sunny cross the bridge by stepping only on light sources!',
      lessonContent: 'You can recognize light sources by their glow. Natural sources like the Sun and fire, and artificial sources like lamps.',
      challengeConfig: {
        gridSize: { rows: 5, cols: 5 },
        lightSourceTiles: ['sun', 'lamp', 'candle', 'torch'],
        startPosition: { row: 0, col: 0 },
        endPosition: { row: 4, col: 4 },
        allowedMoves: 'adjacent'
      },
      hints: [
        'Only step on tiles with light sources',
        'You can move up, down, left, or right',
        'Plan your path before moving'
      ],
      successMessage: 'You made it! Great pathfinding skills!',
      xpReward: 15,
      coinsReward: 7
    },
    {
      levelNumber: 4,
      name: 'Fix the room',
      description: 'Turn on/off lamps to light up a dark room, leaving no dark spots.',
      challengeType: 'puzzle',
      difficultyLevel: 'medium',
      estimatedDurationMinutes: 4,
      storyText: 'This room is too dark! Turn on the right lamps to light it up.',
      lessonContent: 'We use artificial light sources like lamps when natural light isn\'t enough.',
      challengeConfig: {
        room: {
          width: 6,
          height: 6
        },
        lamps: [
          { id: 'lamp1', position: { x: 1, y: 1 }, radius: 2 },
          { id: 'lamp2', position: { x: 4, y: 1 }, radius: 2 },
          { id: 'lamp3', position: { x: 1, y: 4 }, radius: 2 },
          { id: 'lamp4', position: { x: 4, y: 4 }, radius: 2 }
        ],
        targetCoverage: 0.9
      },
      hints: [
        'Each lamp lights up an area around it',
        'Try turning on corner lamps first',
        'Make sure no spots are left dark'
      ],
      successMessage: 'The room is perfectly lit now!',
      xpReward: 18,
      coinsReward: 9
    },
    {
      levelNumber: 5,
      name: 'Match pairs',
      description: 'Memory card game: match light source pictures to their names/icons.',
      challengeType: 'memory_game',
      difficultyLevel: 'easy',
      estimatedDurationMinutes: 3,
      storyText: 'Let\'s play a memory game with light sources!',
      lessonContent: 'There are many types of light sources. Let\'s remember them all!',
      challengeConfig: {
        pairs: [
          { image: 'sun', text: 'Sun' },
          { image: 'lamp', text: 'Lamp' },
          { image: 'torch', text: 'Torch' },
          { image: 'candle', text: 'Candle' },
          { image: 'firefly', text: 'Firefly' },
          { image: 'lightbulb', text: 'Light Bulb' }
        ],
        gridSize: '4x3'
      },
      hints: [
        'Try to remember where each card is',
        'Match the picture to its name',
        'Take your time'
      ],
      successMessage: 'Amazing memory! You matched them all!',
      xpReward: 12,
      coinsReward: 6
    },
    {
      levelNumber: 6,
      name: 'Light vs reflection',
      description: 'Choose which objects make light vs those that only reflect light.',
      challengeType: 'multiple_choice',
      difficultyLevel: 'medium',
      estimatedDurationMinutes: 3,
      storyText: 'Some things make light, others just reflect it. Can you tell the difference?',
      lessonContent: 'Objects that make light are called light sources. Objects that reflect light, like mirrors and the moon, don\'t make their own light.',
      challengeConfig: {
        questions: [
          {
            question: 'Does the Sun make its own light?',
            options: ['Yes, it makes light', 'No, it reflects light'],
            correctAnswer: 0,
            explanation: 'The Sun makes its own light through nuclear reactions.'
          },
          {
            question: 'Does the Moon make its own light?',
            options: ['Yes, it makes light', 'No, it reflects light from the Sun'],
            correctAnswer: 1,
            explanation: 'The Moon only reflects light from the Sun.'
          },
          {
            question: 'Does a mirror make light?',
            options: ['Yes, it makes light', 'No, it only reflects light'],
            correctAnswer: 1,
            explanation: 'Mirrors reflect light but don\'t create it.'
          },
          {
            question: 'Does a campfire make light?',
            options: ['Yes, it makes light', 'No, it reflects light'],
            correctAnswer: 0,
            explanation: 'Fire creates its own light through burning.'
          },
          {
            question: 'Does a shiny spoon make light?',
            options: ['Yes, it makes light', 'No, it only reflects light'],
            correctAnswer: 1,
            explanation: 'Shiny objects reflect light but don\'t create it.'
          }
        ]
      },
      hints: [
        'Light sources create their own light',
        'Reflective objects bounce light from other sources',
        'Think about what happens in a dark room'
      ],
      successMessage: 'Excellent! You understand light vs reflection!',
      xpReward: 15,
      coinsReward: 8
    },
    {
      levelNumber: 7,
      name: 'Right tool',
      description: 'Pick the correct light source for different situations.',
      challengeType: 'matching',
      difficultyLevel: 'medium',
      estimatedDurationMinutes: 3,
      storyText: 'Different situations need different light sources. Can you choose the right one?',
      lessonContent: 'We choose light sources based on what we need: reading needs a steady lamp, camping needs a portable torch.',
      challengeConfig: {
        scenarios: [
          {
            situation: 'Reading a book at night',
            options: ['Table lamp', 'Torch', 'Candle', 'Phone light'],
            correctAnswer: 0,
            reason: 'A table lamp provides steady, bright light perfect for reading.'
          },
          {
            situation: 'Camping in the woods',
            options: ['Ceiling light', 'Torch/Flashlight', 'Desk lamp', 'TV'],
            correctAnswer: 1,
            reason: 'A torch is portable and perfect for outdoor activities.'
          },
          {
            situation: 'Emergency when power is out',
            options: ['Electric lamp', 'Candle', 'Computer screen', 'Microwave'],
            correctAnswer: 1,
            reason: 'Candles work without electricity during power outages.'
          },
          {
            situation: 'Finding something under the bed',
            options: ['Ceiling fan', 'Flashlight', 'Refrigerator light', 'Clock'],
            correctAnswer: 1,
            reason: 'A flashlight can direct light into dark, small spaces.'
          },
          {
            situation: 'Lighting up a birthday cake',
            options: ['Lamp', 'Birthday candles', 'Phone', 'Torch'],
            correctAnswer: 1,
            reason: 'Birthday candles are traditional and safe for cakes.'
          }
        ]
      },
      hints: [
        'Think about which light source is most practical',
        'Consider if you need portability',
        'Some situations have traditional choices'
      ],
      successMessage: 'Perfect! You know the right light for every situation!',
      xpReward: 16,
      coinsReward: 8
    },
    {
      levelNumber: 8,
      name: 'Hide & seek',
      description: 'Reveal hidden objects by selecting correct light sources in different rooms.',
      challengeType: 'interactive_scene',
      difficultyLevel: 'medium',
      estimatedDurationMinutes: 4,
      storyText: 'Objects are hidden in dark rooms. Use the right light sources to find them!',
      lessonContent: 'Light helps us see things. Different light sources work better in different places.',
      challengeConfig: {
        rooms: [
          {
            name: 'Living Room',
            availableLights: ['ceiling_light', 'lamp', 'torch'],
            correctLight: 'ceiling_light',
            hiddenObjects: ['toy', 'book', 'remote']
          },
          {
            name: 'Closet',
            availableLights: ['ceiling_light', 'lamp', 'torch'],
            correctLight: 'torch',
            hiddenObjects: ['shoes', 'jacket', 'hat']
          },
          {
            name: 'Study Desk',
            availableLights: ['ceiling_light', 'desk_lamp', 'torch'],
            correctLight: 'desk_lamp',
            hiddenObjects: ['pencil', 'eraser', 'notebook']
          }
        ]
      },
      hints: [
        'Large rooms need ceiling lights',
        'Small spaces work better with torches',
        'Reading areas need focused light'
      ],
      successMessage: 'You found everything! Great detective work!',
      xpReward: 18,
      coinsReward: 9
    },
    {
      levelNumber: 9,
      name: 'Order of brightness',
      description: 'Arrange 3-4 light sources from dimmest to brightest.',
      challengeType: 'sequencing',
      difficultyLevel: 'medium',
      estimatedDurationMinutes: 3,
      storyText: 'Light sources have different brightness. Can you put them in order?',
      lessonContent: 'Some light sources are brighter than others. The Sun is very bright, while a candle is dim.',
      challengeConfig: {
        sequences: [
          {
            items: ['candle', 'lamp', 'sun'],
            correctOrder: [0, 1, 2],
            description: 'Order from dimmest to brightest'
          },
          {
            items: ['firefly', 'phone_light', 'torch', 'ceiling_light'],
            correctOrder: [0, 1, 2, 3],
            description: 'Order from dimmest to brightest'
          },
          {
            items: ['match', 'candle', 'lamp', 'car_headlight'],
            correctOrder: [0, 1, 2, 3],
            description: 'Order from dimmest to brightest'
          }
        ]
      },
      hints: [
        'The Sun is the brightest natural light',
        'Candles are dimmer than electric lights',
        'Bigger lights are usually brighter'
      ],
      successMessage: 'Perfect order! You understand brightness!',
      xpReward: 16,
      coinsReward: 8
    },
    {
      levelNumber: 10,
      name: 'Story mission',
      description: 'Prepare a night-time picnic by selecting and placing light sources.',
      challengeType: 'interactive_scene',
      difficultyLevel: 'hard',
      estimatedDurationMinutes: 4,
      storyText: 'It\'s time for a magical night picnic! Choose the best lights to make it safe and fun.',
      lessonContent: 'Planning outdoor night activities requires choosing the right combination of light sources for safety and ambiance.',
      challengeConfig: {
        scene: 'night_picnic',
        availableLights: [
          { type: 'lantern', quantity: 3 },
          { type: 'string_lights', quantity: 1 },
          { type: 'torch', quantity: 2 },
          { type: 'candles', quantity: 5 }
        ],
        placementZones: [
          { name: 'picnic_table', requiredLight: 'lantern', count: 2 },
          { name: 'path', requiredLight: 'torch', count: 2 },
          { name: 'trees', requiredLight: 'string_lights', count: 1 },
          { name: 'centerpiece', requiredLight: 'candles', count: 3 }
        ],
        objectives: [
          'Light the path so people can walk safely',
          'Put lanterns on the table for eating',
          'Hang string lights for decoration',
          'Place candles for atmosphere'
        ]
      },
      hints: [
        'Paths need bright, directional light',
        'Tables need steady overhead light',
        'Decorative areas can use softer light',
        'Read each objective carefully'
      ],
      successMessage: 'Amazing! Your night picnic is perfectly lit and safe!',
      xpReward: 20,
      coinsReward: 10
    }
  ],
  topic_p2_day_night: [
    {
      levelNumber: 1,
      name: 'Picture sort',
      description: 'Sort scenes into "day" vs "night".',
      challengeType: 'sort_items',
      difficultyLevel: 'easy',
      estimatedDurationMinutes: 2,
      storyText: 'Welcome to Day and Night Land! Can you tell when these pictures were taken?',
      lessonContent: 'Day is when the Sun is up and it\'s bright. Night is when the Sun is down and it\'s dark.',
      challengeConfig: {
        dayScenes: ['sunny_park', 'school', 'playground', 'beach', 'garden', 'market'],
        nightScenes: ['stars', 'moon', 'sleeping', 'dark_street', 'campfire', 'night_sky'],
        categories: ['Day', 'Night']
      },
      hints: [
        'Look for the Sun or bright sky for day',
        'Stars and moon mean night',
        'Is it bright or dark?'
      ],
      successMessage: 'Great sorting! You know day from night!',
      xpReward: 10,
      coinsReward: 5
    },
    {
      levelNumber: 2,
      name: 'Who is awake?',
      description: 'Match animals/activities to day or night.',
      challengeType: 'matching',
      difficultyLevel: 'easy',
      estimatedDurationMinutes: 3,
      storyText: 'Some creatures love the day, others love the night. Can you match them?',
      lessonContent: 'Some animals are active during the day (diurnal) and others at night (nocturnal).',
      challengeConfig: {
        dayItems: [
          { item: 'going_to_school', type: 'activity' },
          { item: 'butterfly', type: 'animal' },
          { item: 'playing_outside', type: 'activity' },
          { item: 'bird', type: 'animal' },
          { item: 'eating_lunch', type: 'activity' }
        ],
        nightItems: [
          { item: 'sleeping', type: 'activity' },
          { item: 'owl', type: 'animal' },
          { item: 'bat', type: 'animal' },
          { item: 'stargazing', type: 'activity' },
          { item: 'moon_watching', type: 'activity' }
        ]
      },
      hints: [
        'Owls and bats are awake at night',
        'We go to school during the day',
        'Most people sleep at night'
      ],
      successMessage: 'Perfect matching! You know the rhythms of day and night!',
      xpReward: 12,
      coinsReward: 6
    },
    {
      levelNumber: 3,
      name: 'Sky colors',
      description: 'Choose correct sky colors for day and night backgrounds.',
      challengeType: 'multiple_choice',
      difficultyLevel: 'easy',
      estimatedDurationMinutes: 2,
      storyText: 'The sky changes colors between day and night. Let\'s paint it right!',
      lessonContent: 'During the day, the sky is usually blue. At night, the sky is dark blue or black.',
      challengeConfig: {
        scenes: [
          {
            scene: 'noon',
            colorOptions: ['bright_blue', 'dark_blue', 'black', 'orange'],
            correctAnswer: 0,
            explanation: 'The sky is bright blue during the day.'
          },
          {
            scene: 'midnight',
            colorOptions: ['bright_blue', 'light_gray', 'dark_blue', 'yellow'],
            correctAnswer: 2,
            explanation: 'The sky is dark blue or black at night.'
          },
          {
            scene: 'sunset',
            colorOptions: ['bright_blue', 'orange_pink', 'black', 'green'],
            correctAnswer: 1,
            explanation: 'The sky has orange and pink colors at sunset.'
          },
          {
            scene: 'sunrise',
            colorOptions: ['black', 'orange_yellow', 'dark_blue', 'purple'],
            correctAnswer: 1,
            explanation: 'The sky has orange and yellow colors at sunrise.'
          }
        ]
      },
      hints: [
        'Day sky is bright and blue',
        'Night sky is dark',
        'Sunrise and sunset have special colors'
      ],
      successMessage: 'Beautiful! You chose the perfect sky colors!',
      xpReward: 10,
      coinsReward: 5
    },
    {
      levelNumber: 4,
      name: 'Daily routine',
      description: 'Arrange 4 images (wake up, school, dinner, sleep) in correct order.',
      challengeType: 'sequencing',
      difficultyLevel: 'easy',
      estimatedDurationMinutes: 3,
      storyText: 'Every day follows a pattern. Can you put these activities in order?',
      lessonContent: 'Our day has a routine: we wake up in the morning, go to school or play, have dinner, and sleep at night.',
      challengeConfig: {
        sequences: [
          {
            items: ['wake_up', 'breakfast', 'school', 'dinner', 'sleep'],
            correctOrder: [0, 1, 2, 3, 4],
            description: 'Put these daily activities in order'
          },
          {
            items: ['sunrise', 'noon', 'sunset', 'midnight'],
            correctOrder: [0, 1, 2, 3],
            description: 'Put these times of day in order'
          }
        ]
      },
      hints: [
        'We wake up in the morning',
        'School happens during the day',
        'We sleep at night'
      ],
      successMessage: 'Perfect routine! You know how the day flows!',
      xpReward: 12,
      coinsReward: 6
    },
    {
      levelNumber: 5,
      name: 'Clock pictures',
      description: 'Match simple clock faces (sun icon vs moon icon) to day/night scenes.',
      challengeType: 'matching',
      difficultyLevel: 'easy',
      estimatedDurationMinutes: 3,
      storyText: 'Clocks help us know if it\'s day or night. Let\'s match them to the right scenes!',
      lessonContent: 'We use sun and moon symbols to show day and night. The sun symbol means daytime, the moon means nighttime.',
      challengeConfig: {
        clockScenePairs: [
          { clock: 'sun_clock', scene: 'playing_outside', time: 'day' },
          { clock: 'moon_clock', scene: 'sleeping', time: 'night' },
          { clock: 'sun_clock', scene: 'school', time: 'day' },
          { clock: 'moon_clock', scene: 'stars', time: 'night' },
          { clock: 'sun_clock', scene: 'lunch', time: 'day' },
          { clock: 'moon_clock', scene: 'campfire', time: 'night' }
        ]
      },
      hints: [
        'Sun symbol = daytime',
        'Moon symbol = nighttime',
        'Match the symbol to what happens at that time'
      ],
      successMessage: 'Excellent! You can read day and night clocks!',
      xpReward: 12,
      coinsReward: 6
    },
    {
      levelNumber: 6,
      name: 'Street lights',
      description: 'Turn on street lamps only at night scenes, leave them off in day scenes.',
      challengeType: 'interactive_scene',
      difficultyLevel: 'medium',
      estimatedDurationMinutes: 3,
      storyText: 'Street lights save energy by only being on when needed. Can you control them?',
      lessonContent: 'Street lights turn on at night to help people see. During the day, we have sunlight so we turn them off.',
      challengeConfig: {
        scenes: [
          {
            scene: 'street_morning',
            timeOfDay: 'day',
            correctState: 'off',
            feedback: 'Good! We don\'t need street lights during the day.'
          },
          {
            scene: 'street_evening',
            timeOfDay: 'night',
            correctState: 'on',
            feedback: 'Perfect! Street lights help people see at night.'
          },
          {
            scene: 'street_afternoon',
            timeOfDay: 'day',
            correctState: 'off',
            feedback: 'Right! The sun provides light in the afternoon.'
          },
          {
            scene: 'street_midnight',
            timeOfDay: 'night',
            correctState: 'on',
            feedback: 'Yes! Midnight is very dark and needs lights.'
          },
          {
            scene: 'street_noon',
            timeOfDay: 'day',
            correctState: 'off',
            feedback: 'Correct! Noon is the brightest time of day.'
          }
        ]
      },
      hints: [
        'Look at the sky color',
        'Is the sun visible?',
        'Turn lights on only when it\'s dark'
      ],
      successMessage: 'Smart energy use! You know when lights are needed!',
      xpReward: 14,
      coinsReward: 7
    },
    {
      levelNumber: 7,
      name: 'Shadow check',
      description: 'Decide if a strong shadow should appear in a scene.',
      challengeType: 'multiple_choice',
      difficultyLevel: 'medium',
      estimatedDurationMinutes: 3,
      storyText: 'Shadows change during the day. Can you tell when shadows are strong?',
      lessonContent: 'Strong shadows appear when there is bright sunlight. Cloudy days or nighttime have weak or no shadows.',
      challengeConfig: {
        scenarios: [
          {
            scene: 'sunny_playground',
            question: 'Will there be strong shadows?',
            options: ['Yes, strong shadows', 'No shadows'],
            correctAnswer: 0,
            explanation: 'Sunny days create strong, clear shadows.'
          },
          {
            scene: 'cloudy_park',
            question: 'Will there be strong shadows?',
            options: ['Yes, strong shadows', 'No, very faint or no shadows'],
            correctAnswer: 1,
            explanation: 'Cloudy days scatter light, making shadows faint.'
          },
          {
            scene: 'night_street',
            question: 'Will there be shadows from the sun?',
            options: ['Yes', 'No, the sun is not out'],
            correctAnswer: 1,
            explanation: 'At night, there\'s no sunlight to make shadows.'
          },
          {
            scene: 'bright_noon',
            question: 'Will there be strong shadows?',
            options: ['Yes, very strong', 'No'],
            correctAnswer: 0,
            explanation: 'Noon has the brightest sun and strongest shadows.'
          }
        ]
      },
      hints: [
        'Bright sun = strong shadows',
        'Clouds make shadows weak',
        'No sun = no sun shadows'
      ],
      successMessage: 'Excellent! You understand when shadows appear!',
      xpReward: 14,
      coinsReward: 7
    },
    {
      levelNumber: 8,
      name: 'Light needs',
      description: 'Choose if a room needs extra lights (night) or not (day with windows).',
      challengeType: 'multiple_choice',
      difficultyLevel: 'medium',
      estimatedDurationMinutes: 3,
      storyText: 'Some rooms need extra light, others have enough. Can you decide?',
      lessonContent: 'During the day, rooms with windows get sunlight. At night, we need to turn on lights.',
      challengeConfig: {
        rooms: [
          {
            room: 'bedroom_morning_windows',
            question: 'Does this room need lights turned on?',
            options: ['Yes, turn on lights', 'No, sunlight through windows is enough'],
            correctAnswer: 1,
            explanation: 'Windows let in sunlight during the day.'
          },
          {
            room: 'bedroom_night',
            question: 'Does this room need lights turned on?',
            options: ['Yes, it\'s dark', 'No'],
            correctAnswer: 0,
            explanation: 'At night, rooms are dark and need artificial light.'
          },
          {
            room: 'closet_no_windows',
            question: 'Does this closet need lights turned on?',
            options: ['Yes, no windows', 'No'],
            correctAnswer: 0,
            explanation: 'Rooms without windows need lights even during the day.'
          },
          {
            room: 'living_room_afternoon_windows',
            question: 'Does this room need lights turned on?',
            options: ['Yes', 'No, afternoon sun is bright'],
            correctAnswer: 1,
            explanation: 'Afternoon sunlight through windows provides enough light.'
          }
        ]
      },
      hints: [
        'Windows provide daytime light',
        'Nighttime always needs artificial light',
        'Rooms without windows always need lights'
      ],
      successMessage: 'Smart thinking! You save energy and use light wisely!',
      xpReward: 14,
      coinsReward: 7
    },
    {
      levelNumber: 9,
      name: 'Mixed scene puzzle',
      description: 'Tap mistakes (stars in bright blue sky, sun with people sleeping).',
      challengeType: 'tap_objects',
      difficultyLevel: 'medium',
      estimatedDurationMinutes: 3,
      storyText: 'Something is wrong in these pictures! Find what doesn\'t belong.',
      lessonContent: 'Certain things go together: stars go with night, sun goes with day, sleeping goes with night.',
      challengeConfig: {
        scenes: [
          {
            background: 'bright_blue_sky',
            objects: ['sun', 'clouds', 'birds', 'stars', 'airplane'],
            mistakes: ['stars'],
            explanation: 'Stars appear at night, not during the day!'
          },
          {
            background: 'bedroom_with_sun',
            objects: ['bed', 'sun_through_window', 'clock', 'sleeping_person', 'alarm'],
            mistakes: ['sleeping_person'],
            explanation: 'We shouldn\'t be sleeping when the sun is up!'
          },
          {
            background: 'night_sky',
            objects: ['moon', 'stars', 'owl', 'bright_sun', 'bat'],
            mistakes: ['bright_sun'],
            explanation: 'The sun isn\'t out at night!'
          },
          {
            background: 'playground_night',
            objects: ['slide', 'swing', 'moon', 'kids_playing', 'streetlight'],
            mistakes: ['kids_playing'],
            explanation: 'Children usually play during the day, not at night!'
          }
        ]
      },
      hints: [
        'Think about what you see during the day',
        'What belongs at night?',
        'Look for things that don\'t match the time'
      ],
      successMessage: 'Great detective work! You found all the mistakes!',
      xpReward: 16,
      coinsReward: 8
    },
    {
      levelNumber: 10,
      name: 'Story mission',
      description: 'Build a "day in the village" timeline by placing scenes for morning, noon, evening, night.',
      challengeType: 'sequencing',
      difficultyLevel: 'hard',
      estimatedDurationMinutes: 4,
      storyText: 'Let\'s tell the story of a full day in the village! Put the scenes in the right order.',
      lessonContent: 'A full day has many parts: morning (sunrise), afternoon (noon), evening (sunset), and night. Each has its own activities and sky colors.',
      challengeConfig: {
        timeline: {
          totalScenes: 8,
          scenes: [
            {
              id: 'sunrise',
              time: 'early_morning',
              description: 'The sun rises, sky turns orange',
              order: 0
            },
            {
              id: 'breakfast',
              time: 'morning',
              description: 'Families eat breakfast together',
              order: 1
            },
            {
              id: 'school_start',
              time: 'morning',
              description: 'Children go to school',
              order: 2
            },
            {
              id: 'noon',
              time: 'midday',
              description: 'Sun is highest, very bright',
              order: 3
            },
            {
              id: 'afternoon_play',
              time: 'afternoon',
              description: 'Children play after school',
              order: 4
            },
            {
              id: 'sunset',
              time: 'evening',
              description: 'Sun sets, sky turns pink and orange',
              order: 5
            },
            {
              id: 'dinner',
              time: 'evening',
              description: 'Families eat dinner together',
              order: 6
            },
            {
              id: 'bedtime',
              time: 'night',
              description: 'Everyone goes to sleep, stars appear',
              order: 7
            }
          ]
        },
        objectives: [
          'Start with sunrise',
          'Show morning activities',
          'Include the bright noon time',
          'Show evening activities',
          'End with nighttime and bedtime'
        ]
      },
      hints: [
        'The sun rises first (morning)',
        'Noon is in the middle of the day',
        'Sunset happens before dinner',
        'Bedtime is at night'
      ],
      successMessage: 'Perfect story! You understand the flow of a full day!',
      xpReward: 20,
      coinsReward: 10
    }
  ],
  topic_p3_shadows: [
    {
      levelNumber: 1,
      name: 'Find the shadow',
      description: 'Match object to its shadow silhouette.',
      challengeType: 'matching',
      difficultyLevel: 'easy',
      estimatedDurationMinutes: 2,
      storyText: 'Welcome to Shadow Land! Can you match each object to its shadow?',
      lessonContent: 'Shadows are dark shapes that form when an object blocks light. The shadow shape looks like the object.',
      challengeConfig: {
        pairs: [
          { object: 'tree', shadow: 'tree_shadow' },
          { object: 'person', shadow: 'person_shadow' },
          { object: 'ball', shadow: 'ball_shadow' },
          { object: 'house', shadow: 'house_shadow' },
          { object: 'cat', shadow: 'cat_shadow' },
          { object: 'car', shadow: 'car_shadow' }
        ]
      },
      hints: [
        'Look at the shape of the object',
        'The shadow has the same shape but it\'s dark',
        'Match the outlines'
      ],
      successMessage: 'Perfect matching! You understand shadow shapes!',
      xpReward: 10,
      coinsReward: 5
    },
    {
      levelNumber: 2,
      name: 'Make a shadow',
      description: 'Drag an object between a lamp and a wall to create a shadow.',
      challengeType: 'interactive_scene',
      difficultyLevel: 'easy',
      estimatedDurationMinutes: 3,
      storyText: 'Let\'s make shadows! Put the object in the right place between the light and the wall.',
      lessonContent: 'Shadows form when an object blocks light. The light, object, and shadow are always in a line.',
      challengeConfig: {
        scene: {
          lamp: { position: { x: 10, y: 50 } },
          wall: { position: { x: 90, y: 0 }, width: 5, height: 100 },
          object: { type: 'ball', initialPosition: { x: 30, y: 50 } }
        },
        objective: 'Place the ball between the lamp and wall to see its shadow',
        successCriteria: {
          minX: 40,
          maxX: 80,
          showShadow: true
        }
      },
      hints: [
        'The object must be between the light and the wall',
        'Drag the object to block the light',
        'Watch the shadow appear on the wall'
      ],
      successMessage: 'Great! You made a shadow by blocking the light!',
      xpReward: 12,
      coinsReward: 6
    },
    {
      levelNumber: 3,
      name: 'Shadow/no shadow',
      description: 'Decide whether a shadow will appear in each scene.',
      challengeType: 'multiple_choice',
      difficultyLevel: 'easy',
      estimatedDurationMinutes: 3,
      storyText: 'Shadows need light to form. Can you tell which scenes will have shadows?',
      lessonContent: 'Shadows only appear when there is a light source. No light means no shadow.',
      challengeConfig: {
        scenarios: [
          {
            scene: 'person_in_sunlight',
            question: 'Will there be a shadow?',
            options: ['Yes, shadow will appear', 'No shadow'],
            correctAnswer: 0,
            explanation: 'Bright sunlight creates shadows.'
          },
          {
            scene: 'person_in_dark_room',
            question: 'Will there be a shadow?',
            options: ['Yes, shadow will appear', 'No shadow - no light'],
            correctAnswer: 1,
            explanation: 'Without light, shadows cannot form.'
          },
          {
            scene: 'tree_under_streetlight',
            question: 'Will there be a shadow?',
            options: ['Yes, shadow will appear', 'No shadow'],
            correctAnswer: 0,
            explanation: 'The streetlight creates a shadow of the tree.'
          },
          {
            scene: 'ball_in_completely_dark_closet',
            question: 'Will there be a shadow?',
            options: ['Yes', 'No shadow - no light'],
            correctAnswer: 1,
            explanation: 'Shadows need light. No light = no shadow.'
          }
        ]
      },
      hints: [
        'Check if there is a light source',
        'No light = no shadow',
        'Any light source can create shadows'
      ],
      successMessage: 'Excellent! You know when shadows appear!',
      xpReward: 12,
      coinsReward: 6
    },
    {
      levelNumber: 4,
      name: 'Shadow shapes',
      description: 'Choose which shadow belongs to a given object among similar silhouettes.',
      challengeType: 'multiple_choice',
      difficultyLevel: 'medium',
      estimatedDurationMinutes: 3,
      storyText: 'Some shadows look similar. Can you pick the right one?',
      lessonContent: 'Shadow shapes match the outline of objects. Look carefully at the details.',
      challengeConfig: {
        questions: [
          {
            object: 'bicycle',
            shadowOptions: ['bicycle_shadow', 'motorcycle_shadow', 'car_shadow'],
            correctAnswer: 0,
            explanation: 'The bicycle shadow shows two wheels and handlebars.'
          },
          {
            object: 'dog',
            shadowOptions: ['cat_shadow', 'dog_shadow', 'rabbit_shadow'],
            correctAnswer: 1,
            explanation: 'The dog shadow has floppy ears and a tail.'
          },
          {
            object: 'pine_tree',
            shadowOptions: ['pine_tree_shadow', 'round_tree_shadow', 'bush_shadow'],
            correctAnswer: 0,
            explanation: 'Pine trees have a triangle shape.'
          },
          {
            object: 'airplane',
            shadowOptions: ['bird_shadow', 'airplane_shadow', 'helicopter_shadow'],
            correctAnswer: 1,
            explanation: 'Airplane shadows show wings and tail.'
          }
        ]
      },
      hints: [
        'Look at the overall shape',
        'Check for distinctive features',
        'Compare the outlines carefully'
      ],
      successMessage: 'Great eye for detail! You matched all shadows correctly!',
      xpReward: 14,
      coinsReward: 7
    },
    {
      levelNumber: 5,
      name: 'Shadow direction',
      description: 'Tap the correct position of a shadow based on where the light is.',
      challengeType: 'tap_objects',
      difficultyLevel: 'medium',
      estimatedDurationMinutes: 3,
      storyText: 'Shadows appear on the opposite side of the light. Can you tap where the shadow should be?',
      lessonContent: 'Shadows always appear on the side opposite to the light source. If light comes from the left, shadows go to the right.',
      challengeConfig: {
        scenarios: [
          {
            object: 'tree',
            lightPosition: 'left',
            correctShadowPosition: 'right',
            options: ['left', 'right', 'top', 'bottom']
          },
          {
            object: 'person',
            lightPosition: 'right',
            correctShadowPosition: 'left',
            options: ['left', 'right', 'top', 'bottom']
          },
          {
            object: 'flagpole',
            lightPosition: 'top_right',
            correctShadowPosition: 'bottom_left',
            options: ['top_left', 'top_right', 'bottom_left', 'bottom_right']
          },
          {
            object: 'house',
            lightPosition: 'bottom_right',
            correctShadowPosition: 'top_left',
            options: ['top_left', 'top_right', 'bottom_left', 'bottom_right']
          }
        ]
      },
      hints: [
        'Shadow is opposite to the light',
        'If light is on the left, shadow is on the right',
        'Light and shadow are on opposite sides'
      ],
      successMessage: 'Perfect! You understand shadow direction!',
      xpReward: 15,
      coinsReward: 8
    },
    {
      levelNumber: 6,
      name: 'Missing object',
      description: 'Show a shadow, ask child to pick the correct object that makes it.',
      challengeType: 'multiple_choice',
      difficultyLevel: 'medium',
      estimatedDurationMinutes: 3,
      storyText: 'Here are shadows, but where are the objects? Can you figure out what made each shadow?',
      lessonContent: 'We can identify objects by looking at their shadows. The shadow shape tells us about the object.',
      challengeConfig: {
        questions: [
          {
            shadow: 'round_ball_shadow',
            objectOptions: ['ball', 'box', 'pyramid', 'stick'],
            correctAnswer: 0,
            explanation: 'A round shadow comes from a ball.'
          },
          {
            shadow: 'person_with_arms_out_shadow',
            objectOptions: ['tree', 'person_with_arms_out', 'car', 'house'],
            correctAnswer: 1,
            explanation: 'The shadow shows a person with arms stretched out.'
          },
          {
            shadow: 'cup_shadow',
            objectOptions: ['plate', 'cup', 'ball', 'spoon'],
            correctAnswer: 1,
            explanation: 'The shadow has a handle, so it\'s a cup.'
          },
          {
            shadow: 'umbrella_shadow',
            objectOptions: ['umbrella', 'cone', 'bowl', 'hat'],
            correctAnswer: 0,
            explanation: 'The curved top and handle show it\'s an umbrella.'
          }
        ]
      },
      hints: [
        'Look at the shape of the shadow',
        'Think about what objects have that shape',
        'Look for special features like handles'
      ],
      successMessage: 'Amazing! You can identify objects by their shadows!',
      xpReward: 15,
      coinsReward: 8
    },
    {
      levelNumber: 7,
      name: 'Shadow pairs',
      description: 'Match bigger/smaller shadows to "closer to light" vs "farther".',
      challengeType: 'matching',
      difficultyLevel: 'medium',
      estimatedDurationMinutes: 3,
      storyText: 'Shadow size changes! Can you tell which object is closer to the light?',
      lessonContent: 'Objects closer to the light make bigger shadows. Objects farther from the light make smaller shadows.',
      challengeConfig: {
        pairs: [
          {
            scenario: 'two_balls_and_lamp',
            bigShadow: 'ball_A',
            smallShadow: 'ball_B',
            question: 'Which ball is closer to the light?',
            correctAnswer: 'ball_A'
          },
          {
            scenario: 'two_hands_and_lamp',
            bigShadow: 'hand_near_light',
            smallShadow: 'hand_far_from_light',
            question: 'Which hand is farther from the light?',
            correctAnswer: 'hand_far_from_light'
          },
          {
            scenario: 'two_toys',
            bigShadow: 'toy_1',
            smallShadow: 'toy_2',
            question: 'Which toy is closer to the light?',
            correctAnswer: 'toy_1'
          }
        ]
      },
      hints: [
        'Bigger shadow = closer to light',
        'Smaller shadow = farther from light',
        'Move closer to make shadow bigger'
      ],
      successMessage: 'Excellent! You understand how distance affects shadow size!',
      xpReward: 16,
      coinsReward: 8
    },
    {
      levelNumber: 8,
      name: 'Time of day hint',
      description: 'Pick which shadow length (long/short) fits morning vs noon.',
      challengeType: 'multiple_choice',
      difficultyLevel: 'medium',
      estimatedDurationMinutes: 3,
      storyText: 'Shadows change length during the day. Can you match shadow lengths to times?',
      lessonContent: 'At noon, the sun is high and shadows are short. In morning and evening, the sun is low and shadows are long.',
      challengeConfig: {
        questions: [
          {
            timeOfDay: 'noon',
            shadowOptions: ['very_long_shadow', 'short_shadow', 'no_shadow'],
            correctAnswer: 1,
            explanation: 'At noon, the sun is directly above, making short shadows.'
          },
          {
            timeOfDay: 'early_morning',
            shadowOptions: ['short_shadow', 'long_shadow', 'no_shadow'],
            correctAnswer: 1,
            explanation: 'In the morning, the sun is low, making long shadows.'
          },
          {
            timeOfDay: 'late_afternoon',
            shadowOptions: ['short_shadow', 'long_shadow', 'no_shadow'],
            correctAnswer: 1,
            explanation: 'In late afternoon, the sun is low, making long shadows.'
          },
          {
            timeOfDay: 'midday',
            shadowOptions: ['very_long_shadow', 'medium_shadow', 'very_short_shadow'],
            correctAnswer: 2,
            explanation: 'Midday sun is high, creating very short shadows.'
          }
        ]
      },
      hints: [
        'High sun = short shadows (noon)',
        'Low sun = long shadows (morning/evening)',
        'Think about where the sun is in the sky'
      ],
      successMessage: 'Great! You know how shadows change during the day!',
      xpReward: 15,
      coinsReward: 8
    },
    {
      levelNumber: 9,
      name: 'Shadow maze',
      description: 'Move character so its shadow falls on all switches to open a door.',
      challengeType: 'puzzle',
      difficultyLevel: 'hard',
      estimatedDurationMinutes: 4,
      storyText: 'Use your shadow to activate switches! Move carefully to reach all switches.',
      lessonContent: 'Shadows move with us and with the light. We can use shadows to interact with things!',
      challengeConfig: {
        maze: {
          gridSize: { rows: 6, cols: 6 },
          lightSource: { position: { row: 0, col: 3 }, direction: 'down' },
          character: { startPosition: { row: 1, col: 3 } },
          switches: [
            { position: { row: 3, col: 3 } },
            { position: { row: 2, col: 1 } },
            { position: { row: 4, col: 5 } }
          ],
          door: { position: { row: 5, col: 5 } },
          obstacles: [
            { position: { row: 2, col: 2 } },
            { position: { row: 3, col: 4 } }
          ]
        },
        shadowMechanic: 'Shadow falls one tile below character (due to light from above)',
        objective: 'Position yourself so your shadow activates all switches'
      },
      hints: [
        'Your shadow falls below you',
        'Stand one tile above each switch',
        'Plan your route to hit all switches'
      ],
      successMessage: 'Brilliant shadow work! You opened the door!',
      xpReward: 20,
      coinsReward: 10
    },
    {
      levelNumber: 10,
      name: 'Story mission',
      description: 'Use light and object positions to create specific shadow shapes.',
      challengeType: 'interactive_scene',
      difficultyLevel: 'hard',
      estimatedDurationMinutes: 4,
      storyText: 'The shadow puppet show is starting! Create the right shadows for the story.',
      lessonContent: 'Shadow puppets use light and objects to create shapes. By changing the object\'s position and angle, we can make different shadow shapes!',
      challengeConfig: {
        story: {
          scenes: [
            {
              narration: 'Once upon a time, there was a tall tree.',
              targetShadow: 'tall_tree_shadow',
              availableObjects: ['tree_figure', 'person_figure', 'house_figure'],
              lightPosition: 'left',
              correctObject: 'tree_figure',
              correctPosition: { x: 50, y: 50 },
              correctRotation: 0
            },
            {
              narration: 'A little bird flew by.',
              targetShadow: 'bird_flying_shadow',
              availableObjects: ['bird_figure', 'cat_figure', 'butterfly_figure'],
              lightPosition: 'right',
              correctObject: 'bird_figure',
              correctPosition: { x: 50, y: 30 },
              correctRotation: 45
            },
            {
              narration: 'And a friendly rabbit hopped along.',
              targetShadow: 'rabbit_hopping_shadow',
              availableObjects: ['rabbit_figure', 'dog_figure', 'cat_figure'],
              lightPosition: 'left',
              correctObject: 'rabbit_figure',
              correctPosition: { x: 50, y: 50 },
              correctRotation: 0
            }
          ]
        },
        objectives: [
          'Choose the right object',
          'Position it correctly',
          'Match the target shadow shape',
          'Complete all scenes'
        ]
      },
      hints: [
        'Look at the target shadow shape',
        'Choose the matching object',
        'Position it between the light and screen',
        'The shadow should match the target'
      ],
      successMessage: 'Beautiful shadow puppet show! You\'re a shadow master!',
      xpReward: 25,
      coinsReward: 12
    }
  ]
};

// Hot and Cold levels
const hotColdLevels = [
  {
    levelNumber: 1,
    name: 'Sort hot/cold',
    description: 'Drag items into "hot" or "cold" baskets.',
    challengeType: 'sort_items',
    difficultyLevel: 'easy',
    estimatedDurationMinutes: 2,
    storyText: 'Welcome to Temperature Land! Can you tell which things are hot and which are cold?',
    lessonContent: 'Some things are hot and can burn us. Other things are cold and feel cool to touch.',
    challengeConfig: {
      hotItems: ['stove', 'hot_tea', 'fire', 'sun', 'oven', 'iron'],
      coldItems: ['ice_cream', 'snow', 'ice_cube', 'frozen_juice', 'refrigerator', 'cold_water'],
      categories: ['Hot', 'Cold']
    },
    hints: [
      'Fire and ovens are hot',
      'Ice and snow are cold',
      'Think about what would feel hot or cold to touch'
    ],
    successMessage: 'Great sorting! You know hot from cold!',
    xpReward: 10,
    coinsReward: 5
  },
  {
    levelNumber: 2,
    name: 'Thermometer icons',
    description: 'Choose correct thermometer icon (red/high vs blue/low) for each object.',
    challengeType: 'matching',
    difficultyLevel: 'easy',
    estimatedDurationMinutes: 3,
    storyText: 'Thermometers help us measure temperature. Red means hot, blue means cold!',
    lessonContent: 'Thermometers show temperature. Red (high) for hot things, blue (low) for cold things.',
    challengeConfig: {
      items: [
        { object: 'boiling_water', correctThermometer: 'red_high', temperature: 'very_hot' },
        { object: 'ice', correctThermometer: 'blue_low', temperature: 'very_cold' },
        { object: 'warm_soup', correctThermometer: 'red_medium', temperature: 'hot' },
        { object: 'cold_juice', correctThermometer: 'blue_medium', temperature: 'cold' },
        { object: 'hot_cocoa', correctThermometer: 'red_medium', temperature: 'hot' },
        { object: 'frozen_popsicle', correctThermometer: 'blue_low', temperature: 'very_cold' }
      ],
      thermometerOptions: ['red_high', 'red_medium', 'blue_medium', 'blue_low']
    },
    hints: [
      'Red thermometers mean hot',
      'Blue thermometers mean cold',
      'Higher red = hotter, lower blue = colder'
    ],
    successMessage: 'Perfect! You can read thermometers!',
    xpReward: 12,
    coinsReward: 6
  },
  {
    levelNumber: 3,
    name: 'Safe or unsafe',
    description: 'Tap items that are too hot to touch with bare hands.',
    challengeType: 'tap_objects',
    difficultyLevel: 'easy',
    estimatedDurationMinutes: 3,
    storyText: 'Safety first! Which of these things are too hot to touch?',
    lessonContent: 'Some hot things can burn us. We must be careful and never touch them with bare hands.',
    challengeConfig: {
      scene: 'kitchen',
      safeToTouch: ['table', 'book', 'cold_water_glass', 'plate', 'fruit'],
      unsafeToTouch: ['hot_stove', 'boiling_pot', 'hot_oven', 'iron', 'hot_pan'],
      task: 'Tap all the things that are TOO HOT to touch'
    },
    hints: [
      'Stoves and ovens get very hot',
      'Boiling water is too hot to touch',
      'Irons are hot when turned on'
    ],
    successMessage: 'Excellent! You know what\'s safe and unsafe!',
    xpReward: 12,
    coinsReward: 6
  },
  {
    levelNumber: 4,
    name: 'Dress for weather',
    description: 'Choose clothes for hot vs cold days.',
    challengeType: 'matching',
    difficultyLevel: 'easy',
    estimatedDurationMinutes: 3,
    storyText: 'What should we wear? Let\'s dress for the weather!',
    lessonContent: 'We wear different clothes for hot and cold weather. Light clothes for hot days, warm clothes for cold days.',
    challengeConfig: {
      scenarios: [
        {
          weather: 'hot_sunny_day',
          correctClothes: ['t_shirt', 'shorts', 'sandals', 'sun_hat'],
          wrongClothes: ['winter_coat', 'boots', 'scarf', 'gloves']
        },
        {
          weather: 'cold_snowy_day',
          correctClothes: ['winter_coat', 'warm_pants', 'boots', 'hat', 'scarf', 'gloves'],
          wrongClothes: ['t_shirt', 'shorts', 'sandals', 'swimsuit']
        },
        {
          weather: 'hot_beach_day',
          correctClothes: ['swimsuit', 'flip_flops', 'sun_hat', 'light_shirt'],
          wrongClothes: ['heavy_jacket', 'thick_pants', 'winter_boots']
        }
      ]
    },
    hints: [
      'Hot weather needs light, cool clothes',
      'Cold weather needs warm, heavy clothes',
      'Think about being comfortable'
    ],
    successMessage: 'Perfect outfit choices! You dress for the weather!',
    xpReward: 12,
    coinsReward: 6
  },
  {
    levelNumber: 5,
    name: 'Change state',
    description: 'Watch water ice cube melting near heat; answer hot/cold questions.',
    challengeType: 'interactive_scene',
    difficultyLevel: 'medium',
    estimatedDurationMinutes: 3,
    storyText: 'Watch what happens when ice meets heat!',
    lessonContent: 'Heat can change things. Ice melts when it gets warm. Cold things become warm when heated.',
    challengeConfig: {
      animation: {
        scene: 'ice_cube_near_heat_source',
        stages: [
          { time: 0, state: 'solid_ice', description: 'Ice cube is solid and cold' },
          { time: 5, state: 'starting_to_melt', description: 'Ice starts to melt' },
          { time: 10, state: 'mostly_water', description: 'Most of the ice is now water' },
          { time: 15, state: 'all_water', description: 'All ice has melted to water' }
        ]
      },
      questions: [
        {
          question: 'What made the ice melt?',
          options: ['The heat', 'The cold', 'Nothing'],
          correctAnswer: 0
        },
        {
          question: 'What did the ice turn into?',
          options: ['Water', 'Steam', 'Nothing changed'],
          correctAnswer: 0
        },
        {
          question: 'Was the heat source hot or cold?',
          options: ['Hot', 'Cold'],
          correctAnswer: 0
        }
      ]
    },
    hints: [
      'Heat makes ice melt',
      'Ice turns into water when it melts',
      'Melting happens because of heat'
    ],
    successMessage: 'Great observation! Heat changes ice to water!',
    xpReward: 14,
    coinsReward: 7
  },
  {
    levelNumber: 6,
    name: 'Kitchen safety',
    description: 'Tap dangerous hot spots in a cartoon kitchen.',
    challengeType: 'tap_objects',
    difficultyLevel: 'medium',
    estimatedDurationMinutes: 3,
    storyText: 'Kitchens have many hot things. Can you spot all the hot spots?',
    lessonContent: 'Kitchens are full of things that can get hot. We must be careful around stoves, ovens, and hot foods.',
    challengeConfig: {
      scene: 'kitchen_with_appliances',
      hotSpots: [
        { object: 'stove_with_pot', danger: 'high' },
        { object: 'oven_on', danger: 'high' },
        { object: 'toaster_in_use', danger: 'medium' },
        { object: 'kettle_boiling', danger: 'high' },
        { object: 'hot_pan', danger: 'high' },
        { object: 'microwave_running', danger: 'medium' }
      ],
      safeObjects: ['refrigerator', 'sink', 'table', 'chair', 'cabinet'],
      task: 'Tap all the dangerous hot spots'
    },
    hints: [
      'Look for appliances that cook or heat',
      'Stoves and ovens are always hot when on',
      'Boiling kettles are dangerous'
    ],
    successMessage: 'Excellent safety awareness! You found all hot spots!',
    xpReward: 15,
    coinsReward: 8
  },
  {
    levelNumber: 7,
    name: 'Warm it up',
    description: 'Choose ways to warm an object (sun, fire, heater).',
    challengeType: 'multiple_choice',
    difficultyLevel: 'medium',
    estimatedDurationMinutes: 3,
    storyText: 'How can we make cold things warm? Let\'s find out!',
    lessonContent: 'We can warm things using heat sources like the sun, fire, or heaters. These add heat to make cold things warm.',
    challengeConfig: {
      scenarios: [
        {
          object: 'cold_hands',
          question: 'How can you warm your cold hands?',
          options: ['Rub them together', 'Put them in the freezer', 'Blow cold air on them', 'Put them in water with ice'],
          correctAnswers: [0],
          explanation: 'Rubbing creates friction and heat, warming your hands.'
        },
        {
          object: 'cold_room',
          question: 'How can you warm a cold room?',
          options: ['Turn on a heater', 'Open the windows', 'Turn on a fan', 'Add ice'],
          correctAnswers: [0],
          explanation: 'Heaters produce heat to warm rooms.'
        },
        {
          object: 'cold_food',
          question: 'How can you warm cold food?',
          options: ['Microwave it', 'Put it in the refrigerator', 'Put it in the freezer', 'Add ice to it'],
          correctAnswers: [0],
          explanation: 'Microwaves heat food quickly.'
        },
        {
          object: 'cold_water',
          question: 'How can you warm cold water?',
          options: ['Heat it on a stove', 'Add ice cubes', 'Put it in a cold place', 'Blow on it'],
          correctAnswers: [0],
          explanation: 'Stoves provide heat to warm water.'
        }
      ]
    },
    hints: [
      'Think about things that produce heat',
      'Sun, fire, and heaters make things warm',
      'Avoid options that make things colder'
    ],
    successMessage: 'Great! You know how to warm things up!',
    xpReward: 14,
    coinsReward: 7
  },
  {
    levelNumber: 8,
    name: 'Cool it down',
    description: 'Choose correct coolers (shade, fridge, ice) for hot items.',
    challengeType: 'multiple_choice',
    difficultyLevel: 'medium',
    estimatedDurationMinutes: 3,
    storyText: 'Sometimes we need to cool things down. What works best?',
    lessonContent: 'We can cool things using shade, refrigerators, ice, or moving to cold places. These remove heat to make hot things cool.',
    challengeConfig: {
      scenarios: [
        {
          object: 'hot_drink',
          question: 'How can you cool down a hot drink?',
          options: ['Add ice cubes', 'Heat it more', 'Put it in the oven', 'Cover it with a hot blanket'],
          correctAnswers: [0],
          explanation: 'Ice cubes are cold and will cool the drink.'
        },
        {
          object: 'hot_leftovers',
          question: 'Where should you put hot leftovers to cool them?',
          options: ['In the refrigerator (after cooling slightly)', 'In the oven', 'Next to the stove', 'In hot water'],
          correctAnswers: [0],
          explanation: 'Refrigerators keep food cool and fresh.'
        },
        {
          object: 'person_feeling_hot',
          question: 'How can you cool down on a hot day?',
          options: ['Go in the shade', 'Stand in the sun', 'Wear a thick jacket', 'Run around'],
          correctAnswers: [0],
          explanation: 'Shade blocks the sun and is cooler.'
        },
        {
          object: 'warm_juice_box',
          question: 'How can you make warm juice cold?',
          options: ['Put it in the freezer for a bit', 'Leave it in the sun', 'Shake it', 'Heat it up'],
          correctAnswers: [0],
          explanation: 'Freezers make things very cold.'
        }
      ]
    },
    hints: [
      'Think about things that are cold',
      'Refrigerators and ice cool things',
      'Shade is cooler than sunlight'
    ],
    successMessage: 'Perfect! You know how to cool things down!',
    xpReward: 14,
    coinsReward: 7
  },
  {
    levelNumber: 9,
    name: 'Sequence',
    description: 'Put pictures in order: ice → cold water → warm water.',
    challengeType: 'sequencing',
    difficultyLevel: 'medium',
    estimatedDurationMinutes: 3,
    storyText: 'Things change when they get warmer. Can you put these in order?',
    lessonContent: 'When we add heat, cold things become warm. Ice melts to cold water, then water gets warm.',
    challengeConfig: {
      sequences: [
        {
          items: ['ice_cube', 'cold_water', 'warm_water'],
          correctOrder: [0, 1, 2],
          description: 'Put in order from coldest to warmest',
          story: 'Ice melts to water, then water warms up'
        },
        {
          items: ['frozen_popsicle', 'melting_popsicle', 'liquid_popsicle'],
          correctOrder: [0, 1, 2],
          description: 'What happens to a popsicle in the sun?',
          story: 'Heat makes frozen things melt'
        },
        {
          items: ['cold_butter', 'soft_butter', 'melted_butter'],
          correctOrder: [0, 1, 2],
          description: 'Butter warming up',
          story: 'Butter softens then melts when heated'
        }
      ]
    },
    hints: [
      'Start with the coldest/most frozen',
      'Heat makes things change',
      'End with the warmest/most melted'
    ],
    successMessage: 'Excellent sequencing! You understand temperature changes!',
    xpReward: 15,
    coinsReward: 8
  },
  {
    levelNumber: 10,
    name: 'Story mission',
    description: 'Prepare for a trip to a snowy mountain vs beach by packing correct items.',
    challengeType: 'interactive_scene',
    difficultyLevel: 'hard',
    estimatedDurationMinutes: 4,
    storyText: 'Two trips, two different climates! Pack the right things for each adventure.',
    lessonContent: 'Different places have different temperatures. We need to prepare correctly - warm clothes for cold places, light clothes for hot places.',
    challengeConfig: {
      trips: [
        {
          destination: 'snowy_mountain',
          climate: 'very_cold',
          correctItems: [
            'winter_coat',
            'warm_pants',
            'snow_boots',
            'gloves',
            'scarf',
            'hat',
            'hot_cocoa',
            'warm_socks'
          ],
          wrongItems: [
            'swimsuit',
            'flip_flops',
            'shorts',
            't_shirt',
            'ice_cream',
            'cold_drink',
            'sunscreen'
          ],
          minCorrect: 6
        },
        {
          destination: 'sunny_beach',
          climate: 'very_hot',
          correctItems: [
            'swimsuit',
            'flip_flops',
            'shorts',
            't_shirt',
            'sunscreen',
            'sunglasses',
            'hat',
            'cold_drink',
            'ice_cream'
          ],
          wrongItems: [
            'winter_coat',
            'snow_boots',
            'thick_pants',
            'scarf',
            'gloves',
            'hot_soup'
          ],
          minCorrect: 6
        }
      ],
      objectives: [
        'Pack appropriate clothes for cold mountain',
        'Include safety items (sunscreen for beach, warm layers for mountain)',
        'Pack appropriate clothes for hot beach',
        'Choose suitable food/drinks for each climate'
      ]
    },
    hints: [
      'Mountains are cold - pack warm things',
      'Beaches are hot - pack light, cool things',
      'Think about safety (sunscreen, warm layers)',
      'Don\'t pack beach clothes for mountains!'
    ],
    successMessage: 'Perfect packing! You\'re ready for any adventure!',
    xpReward: 20,
    coinsReward: 10
  }
];

// Push and Pull levels
const pushPullLevels = [
  {
    levelNumber: 1,
    name: 'Push or pull?',
    description: 'Watch short animations and tap "push" or "pull".',
    challengeType: 'multiple_choice',
    difficultyLevel: 'easy',
    estimatedDurationMinutes: 2,
    storyText: 'Welcome to Force Land! Let\'s learn about pushing and pulling!',
    lessonContent: 'Push means moving something away from you. Pull means bringing something toward you.',
    challengeConfig: {
      animations: [
        {
          animation: 'person_pushing_cart',
          question: 'Is this a push or pull?',
          options: ['Push', 'Pull'],
          correctAnswer: 0,
          explanation: 'Pushing moves the cart away from the person.'
        },
        {
          animation: 'person_pulling_wagon',
          question: 'Is this a push or pull?',
          options: ['Push', 'Pull'],
          correctAnswer: 1,
          explanation: 'Pulling brings the wagon toward the person.'
        },
        {
          animation: 'opening_door_outward',
          question: 'Is this a push or pull?',
          options: ['Push', 'Pull'],
          correctAnswer: 0,
          explanation: 'Pushing the door makes it move away.'
        },
        {
          animation: 'opening_drawer',
          question: 'Is this a push or pull?',
          options: ['Push', 'Pull'],
          correctAnswer: 1,
          explanation: 'Pulling opens the drawer toward you.'
        }
      ]
    },
    hints: [
      'Push = away from you',
      'Pull = toward you',
      'Watch which direction things move'
    ],
    successMessage: 'Great! You know push from pull!',
    xpReward: 10,
    coinsReward: 5
  },
  {
    levelNumber: 2,
    name: 'Sort actions',
    description: 'Drag action cards to "push actions" vs "pull actions".',
    challengeType: 'sort_items',
    difficultyLevel: 'easy',
    estimatedDurationMinutes: 3,
    storyText: 'Let\'s sort these actions! Which are pushes and which are pulls?',
    lessonContent: 'Many everyday activities use pushing or pulling. Let\'s identify them!',
    challengeConfig: {
      pushActions: [
        'push_cart',
        'push_door_open',
        'push_button',
        'push_swing',
        'push_toy_car',
        'push_wheelbarrow'
      ],
      pullActions: [
        'pull_wagon',
        'pull_rope',
        'pull_drawer',
        'pull_door_handle',
        'pull_suitcase',
        'pull_zipper'
      ],
      categories: ['Push Actions', 'Pull Actions']
    },
    hints: [
      'Think about the direction of force',
      'Push moves away, pull brings close',
      'Imagine doing each action'
    ],
    successMessage: 'Perfect sorting! You understand push and pull actions!',
    xpReward: 12,
    coinsReward: 6
  },
  {
    levelNumber: 3,
    name: 'Move the cart',
    description: 'Choose push or pull arrow to move a cart in the right direction.',
    challengeType: 'interactive_scene',
    difficultyLevel: 'easy',
    estimatedDurationMinutes: 3,
    storyText: 'Help move the cart to the goal! Choose the right force.',
    lessonContent: 'We can move objects by pushing or pulling them. The direction we want to go determines which force to use.',
    challengeConfig: {
      scenarios: [
        {
          start: { x: 10, y: 50 },
          goal: { x: 80, y: 50 },
          correctAction: 'push',
          direction: 'right',
          explanation: 'Push from behind to move the cart forward.'
        },
        {
          start: { x: 80, y: 50 },
          goal: { x: 10, y: 50 },
          correctAction: 'pull',
          direction: 'left',
          explanation: 'Pull from the front to bring the cart back.'
        },
        {
          start: { x: 50, y: 80 },
          goal: { x: 50, y: 20 },
          correctAction: 'pull',
          direction: 'up',
          explanation: 'Pull upward to move the cart up.'
        }
      ]
    },
    hints: [
      'Look where the cart needs to go',
      'Push from behind, pull from front',
      'Match the force direction to the goal'
    ],
    successMessage: 'Excellent! You moved the cart perfectly!',
    xpReward: 12,
    coinsReward: 6
  },
  {
    levelNumber: 4,
    name: 'Door game',
    description: 'Decide if we push or pull different doors.',
    challengeType: 'multiple_choice',
    difficultyLevel: 'easy',
    estimatedDurationMinutes: 3,
    storyText: 'Doors can be tricky! Do we push or pull?',
    lessonContent: 'Some doors we push open, others we pull. Often doors have signs or handles that tell us which way.',
    challengeConfig: {
      doors: [
        {
          door: 'door_with_push_plate',
          image: 'flat_push_plate',
          question: 'How do you open this door?',
          options: ['Push', 'Pull'],
          correctAnswer: 0,
          explanation: 'Flat plates mean push.'
        },
        {
          door: 'door_with_handle',
          image: 'door_handle_to_pull',
          question: 'How do you open this door?',
          options: ['Push', 'Pull'],
          correctAnswer: 1,
          explanation: 'Handles mean you pull.'
        },
        {
          door: 'door_with_push_sign',
          image: 'push_sign',
          question: 'How do you open this door?',
          options: ['Push', 'Pull'],
          correctAnswer: 0,
          explanation: 'The sign says "PUSH"!'
        },
        {
          door: 'door_with_pull_sign',
          image: 'pull_sign',
          question: 'How do you open this door?',
          options: ['Push', 'Pull'],
          correctAnswer: 1,
          explanation: 'The sign says "PULL"!'
        },
        {
          door: 'sliding_door',
          image: 'sliding_door',
          question: 'How do you open this door?',
          options: ['Push to the side', 'Pull toward you'],
          correctAnswer: 0,
          explanation: 'Sliding doors you push sideways.'
        }
      ]
    },
    hints: [
      'Look for signs on the door',
      'Flat plates usually mean push',
      'Handles usually mean pull'
    ],
    successMessage: 'Great! You\'ll never get stuck at a door!',
    xpReward: 12,
    coinsReward: 6
  },
  {
    levelNumber: 5,
    name: 'Rope vs ball',
    description: 'Choose the correct action (pull rope, push ball) to reach a goal.',
    challengeType: 'interactive_scene',
    difficultyLevel: 'medium',
    estimatedDurationMinutes: 3,
    storyText: 'Some objects work better with pushing, others with pulling. Choose wisely!',
    lessonContent: 'Different objects are easier to move in different ways. Ropes are easier to pull, balls are easier to push or roll.',
    challengeConfig: {
      scenarios: [
        {
          object: 'rope_attached_to_box',
          goal: 'bring_box_closer',
          options: ['Push the rope', 'Pull the rope'],
          correctAnswer: 1,
          explanation: 'Pulling a rope brings things closer.',
          effect: 'box_moves_toward_player'
        },
        {
          object: 'ball_in_front',
          goal: 'move_ball_forward',
          options: ['Push the ball', 'Pull the ball'],
          correctAnswer: 0,
          explanation: 'Balls are easy to push and roll.',
          effect: 'ball_rolls_forward'
        },
        {
          object: 'wagon_with_handle',
          goal: 'bring_wagon_closer',
          options: ['Push the wagon', 'Pull the wagon'],
          correctAnswer: 1,
          explanation: 'Wagons with handles are designed to be pulled.',
          effect: 'wagon_comes_toward_player'
        },
        {
          object: 'toy_car',
          goal: 'move_car_forward',
          options: ['Push the car', 'Pull the car'],
          correctAnswer: 0,
          explanation: 'Toy cars with wheels roll easily when pushed.',
          effect: 'car_rolls_forward'
        }
      ]
    },
    hints: [
      'Ropes work better with pulling',
      'Balls and cars are easier to push',
      'Think about how each object moves best'
    ],
    successMessage: 'Smart choices! You matched actions to objects!',
    xpReward: 14,
    coinsReward: 7
  },
  {
    levelNumber: 6,
    name: 'Team push',
    description: 'Combine two characters pushing to move a heavy object.',
    challengeType: 'interactive_scene',
    difficultyLevel: 'medium',
    estimatedDurationMinutes: 3,
    storyText: 'This object is too heavy for one person! Let\'s work together!',
    lessonContent: 'When objects are heavy, we need more force. Multiple people pushing together can move heavy things.',
    challengeConfig: {
      scenarios: [
        {
          object: 'heavy_box',
          weight: 'very_heavy',
          attempts: [
            { characters: 1, result: 'box_doesnt_move', message: 'Too heavy for one person!' },
            { characters: 2, result: 'box_moves_slowly', message: 'Two people can move it!' },
            { characters: 3, result: 'box_moves_easily', message: 'Three people make it easy!' }
          ],
          task: 'Add enough characters to move the box',
          minCharacters: 2
        },
        {
          object: 'stuck_car',
          weight: 'heavy',
          attempts: [
            { characters: 1, result: 'car_doesnt_move', message: 'Not enough force!' },
            { characters: 2, result: 'car_starts_moving', message: 'Working together works!' }
          ],
          task: 'Get enough people to push the car',
          minCharacters: 2
        }
      ]
    },
    hints: [
      'More pushers = more force',
      'Heavy objects need teamwork',
      'Try adding more characters'
    ],
    successMessage: 'Teamwork makes it work! Great job!',
    xpReward: 15,
    coinsReward: 8
  },
  {
    levelNumber: 7,
    name: 'Stop or go',
    description: 'Choose a push to start motion and another push/pull to stop.',
    challengeType: 'interactive_scene',
    difficultyLevel: 'medium',
    estimatedDurationMinutes: 3,
    storyText: 'Forces can start motion and stop it too! Let\'s control a moving cart.',
    lessonContent: 'Pushing can make things start moving. Pushing or pulling in the opposite direction can make things stop.',
    challengeConfig: {
      scenarios: [
        {
          object: 'cart_at_rest',
          phase: 'start',
          question: 'How do you make the cart start moving forward?',
          options: ['Push forward', 'Pull backward', 'Do nothing'],
          correctAnswer: 0,
          effect: 'cart_starts_rolling_forward'
        },
        {
          object: 'cart_moving_forward',
          phase: 'stop',
          question: 'How do you make the cart stop?',
          options: ['Push backward', 'Push forward more', 'Let it go'],
          correctAnswer: 0,
          effect: 'cart_stops'
        },
        {
          object: 'swing',
          phase: 'start',
          question: 'How do you make the swing start moving?',
          options: ['Push the swing', 'Pull the swing', 'Watch it'],
          correctAnswer: 0,
          effect: 'swing_starts_moving'
        },
        {
          object: 'swing_moving',
          phase: 'stop',
          question: 'How do you stop the swing?',
          options: ['Catch and hold it (pull)', 'Push it harder', 'Close your eyes'],
          correctAnswer: 0,
          effect: 'swing_stops'
        }
      ]
    },
    hints: [
      'Push to start movement',
      'Push/pull opposite direction to stop',
      'Forces control motion'
    ],
    successMessage: 'Perfect control! You understand forces and motion!',
    xpReward: 15,
    coinsReward: 8
  },
  {
    levelNumber: 8,
    name: 'Obstacle puzzle',
    description: 'Use push/pull icons to move boxes out of the way.',
    challengeType: 'puzzle',
    difficultyLevel: 'medium',
    estimatedDurationMinutes: 4,
    storyText: 'Boxes are blocking the path! Move them using pushes and pulls.',
    lessonContent: 'We can use pushing and pulling strategically to solve problems and clear paths.',
    challengeConfig: {
      puzzles: [
        {
          grid: { rows: 5, cols: 5 },
          player: { start: { row: 0, col: 0 } },
          goal: { row: 4, col: 4 },
          boxes: [
            { id: 'box1', position: { row: 2, col: 2 }, movable: true },
            { id: 'box2', position: { row: 3, col: 2 }, movable: true }
          ],
          walls: [
            { row: 1, col: 3 },
            { row: 2, col: 3 }
          ],
          solution: [
            'Push box1 right',
            'Push box2 down',
            'Walk around to goal'
          ]
        },
        {
          grid: { rows: 6, cols: 6 },
          player: { start: { row: 0, col: 2 } },
          goal: { row: 5, col: 2 },
          boxes: [
            { id: 'box1', position: { row: 3, col: 2 }, movable: true },
            { id: 'box2', position: { row: 3, col: 1 }, movable: true },
            { id: 'box3', position: { row: 3, col: 3 }, movable: true }
          ],
          solution: [
            'Push box2 left',
            'Push box3 right',
            'Push box1 down',
            'Walk to goal'
          ]
        }
      ]
    },
    hints: [
      'You can only push boxes, not pull',
      'Plan your moves carefully',
      'Clear a path to the goal'
    ],
    successMessage: 'Brilliant! You cleared all obstacles!',
    xpReward: 18,
    coinsReward: 9
  },
  {
    levelNumber: 9,
    name: 'Direction arrows',
    description: 'Arrange arrows showing sequence of pushes/pulls to move object around maze.',
    challengeType: 'sequencing',
    difficultyLevel: 'hard',
    estimatedDurationMinutes: 4,
    storyText: 'Plan your pushes and pulls! Arrange the arrows in the right order.',
    lessonContent: 'We can plan a sequence of forces to move objects along a specific path.',
    challengeConfig: {
      mazes: [
        {
          object: 'ball',
          start: { row: 0, col: 0 },
          goal: { row: 2, col: 2 },
          path: 'L-shaped',
          correctSequence: [
            { action: 'push', direction: 'right' },
            { action: 'push', direction: 'right' },
            { action: 'push', direction: 'down' },
            { action: 'push', direction: 'down' }
          ],
          availableArrows: [
            { action: 'push', direction: 'right', count: 3 },
            { action: 'push', direction: 'down', count: 3 },
            { action: 'push', direction: 'left', count: 1 },
            { action: 'push', direction: 'up', count: 1 }
          ]
        },
        {
          object: 'cart',
          start: { row: 1, col: 3 },
          goal: { row: 3, col: 0 },
          path: 'zig-zag',
          correctSequence: [
            { action: 'push', direction: 'down' },
            { action: 'push', direction: 'left' },
            { action: 'push', direction: 'down' },
            { action: 'push', direction: 'left' },
            { action: 'push', direction: 'left' }
          ],
          availableArrows: [
            { action: 'push', direction: 'down', count: 4 },
            { action: 'push', direction: 'left', count: 4 },
            { action: 'push', direction: 'right', count: 2 }
          ]
        }
      ]
    },
    hints: [
      'Follow the path from start to goal',
      'Each arrow is one push',
      'Put arrows in order: first push, second push, etc.'
    ],
    successMessage: 'Perfect planning! You\'re a force master!',
    xpReward: 18,
    coinsReward: 9
  },
  {
    levelNumber: 10,
    name: 'Story mission',
    description: 'Use push and pull actions in right order to help character cross bridge.',
    challengeType: 'interactive_scene',
    difficultyLevel: 'hard',
    estimatedDurationMinutes: 4,
    storyText: 'The bridge is broken! Use pushes and pulls to build a path and cross safely.',
    lessonContent: 'Solving complex problems requires using multiple forces in the right sequence. Plan carefully!',
    challengeConfig: {
      story: {
        setting: 'broken_bridge_over_river',
        character: 'brave_explorer',
        goal: 'cross_the_bridge',
        tasks: [
          {
            step: 1,
            description: 'Pull the rope to bring the platform closer',
            action: 'pull',
            object: 'rope_attached_to_platform',
            success: 'platform_moves_closer'
          },
          {
            step: 2,
            description: 'Push the heavy log onto the platform',
            action: 'push',
            object: 'heavy_log',
            success: 'log_on_platform'
          },
          {
            step: 3,
            description: 'Pull the platform with the log to the middle of the river',
            action: 'pull',
            object: 'rope',
            success: 'platform_in_middle'
          },
          {
            step: 4,
            description: 'Push the log from the platform to bridge the gap',
            action: 'push',
            object: 'log_on_platform',
            success: 'log_bridges_gap'
          },
          {
            step: 5,
            description: 'Walk across the log bridge!',
            action: 'walk',
            object: 'log_bridge',
            success: 'crossed_safely'
          }
        ],
        wrongActionsGiveFeedback: true,
        allowRetry: true
      }
    },
    hints: [
      'Read each step carefully',
      'Some tasks need pull, others need push',
      'Complete tasks in order',
      'Use the right force for each step'
    ],
    successMessage: 'Incredible! You used forces perfectly to solve the problem!',
    xpReward: 25,
    coinsReward: 12
  }
];

// Add to levelsData object
levelsData.topic_p4_hot_cold = hotColdLevels;
levelsData.topic_p5_push_pull = pushPullLevels;

async function seedPhysicsIsland() {
  try {
    console.log('🌱 Starting Physics Island seeding...');

    // Find or create the Physics Island
    const [island, islandCreated] = await Island.findOrCreate({
      where: { code: physicsIslandData.code },
      defaults: physicsIslandData
    });

    if (islandCreated) {
      console.log(`✅ Created island: ${island.name}`);
    } else {
      console.log(`ℹ️  Island already exists: ${island.name}`);
    }

    // Create/Update topics
    for (const topicData of physicsTopics) {
      const [topic, topicCreated] = await Topic.findOrCreate({
        where: { code: topicData.code },
        defaults: {
          ...topicData,
          islandId: island.id
        }
      });

      if (topicCreated) {
        console.log(`✅ Created topic: ${topic.name}`);
      } else {
        console.log(`ℹ️  Topic already exists: ${topic.name}`);
        // Update the topic in case data changed
        await topic.update({
          ...topicData,
          islandId: island.id
        });
      }

      // Create levels for this topic
      const topicLevels = levelsData[topicData.code];
      if (topicLevels) {
        for (const levelData of topicLevels) {
          const levelCode = `${topicData.code}_level_${levelData.levelNumber}`;
          const [level, levelCreated] = await Level.findOrCreate({
            where: { code: levelCode },
            defaults: {
              ...levelData,
              code: levelCode,
              topicId: topic.id
            }
          });

          if (levelCreated) {
            console.log(`  ✅ Created level ${levelData.levelNumber}: ${levelData.name}`);
          } else {
            console.log(`  ℹ️  Level ${levelData.levelNumber} already exists: ${levelData.name}`);
            // Update level data
            await level.update({
              ...levelData,
              topicId: topic.id
            });
          }
        }
      }
    }

    console.log('🎉 Physics Island seeding completed successfully!');
    console.log(`📊 Summary:
      - Island: ${island.name}
      - Topics: ${physicsTopics.length}
      - Total Levels: ${physicsTopics.reduce((sum, t) => sum + t.levelCount, 0)}
    `);

  } catch (error) {
    console.error('❌ Error seeding Physics Island:', error);
    throw error;
  }
}

// Run if called directly
if (require.main === module) {
  seedPhysicsIsland()
    .then(() => {
      console.log('Closing database connection...');
      return sequelize.close();
    })
    .then(() => {
      console.log('✅ Done!');
      process.exit(0);
    })
    .catch((error) => {
      console.error('Fatal error:', error);
      process.exit(1);
    });
}

module.exports = { seedPhysicsIsland, physicsIslandData, physicsTopics, levelsData };
