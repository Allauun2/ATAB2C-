class GetProviders {
  static int clientId = 2;
  static List<Map<String, dynamic>> popularCities = [
    {'name': 'Mogadishu', 'code': 'MGQ'},
    {'name': 'Hargeisa', 'code': 'HGA'},
  ];

  static List<String> providers = [
    "TravelC",
    "StarSky",
    "Siliconsom",
    "Royal",
    // Rayaan Air — the portal searches it too; leaving it out hid its flights.
    "Rayaan",
  ];

  // static List<Map<String, dynamic>> providers = [
  //   {
  //     "clientId": clientId,
  //     "provider": "Siliconsom",
  //   },
  //   {
  //     "clientId": clientId,
  //     "provider": "Royal",
  //   },
  //   {
  //     "clientId": clientId,
  //     "provider": "StarSky",
  //   },
  //   {
  //     "clientId": clientId,
  //     "provider": "TravelC",
  //   },
  // ];

  static List<Map<String, dynamic>> cityData = [
    {
      "name": 'Popular Destinations',
      "value": [
        {
          "name": 'Mogadishu',
          "code": "MGQ",
          "value": 'MGQ,Mogadishu',
        },
        {
          "name": 'Nairobi',
          "code": "NBO",
          "value": 'NBO,Nairobi',
        }
      ]
    },
    {
      "name": 'Somalia',
      "value": [
        {
          "name": 'Mogadishu',
          "code": "MGQ",
          "value": 'Mogadishu, SOMALIA (MGQ)',
        },
        {
          "name": 'Galkayo',
          "code": "GLK-O",
          "value": 'Galkayo, SOMALIA (GLK-O)',
        },
        {
          "name": 'Abudwak',
          "code": "ABW",
          "value": 'Abudwak, SOMALIA (ABW)',
        },
        {
          "name": 'Baydhabo',
          "code": "BIB",
          "value": 'Baidoa, SOMALIA (BIB)',
        },
        {
          "name": 'Bosaso',
          "code": "BSA",
          "value": 'Bosaso, SOMALIA (BSA)',
        },
        {
          "name": 'Dhobley',
          "code": "DLY",
          "value": 'Dhobley, SOMALIA (DLY)',
        },
        {
          "name": 'Hargeisa',
          "code": "HGA",
          "value": 'Hargeisa, SOMALIA (HGA)',
        },
        {
          "name": 'Kismayo',
          "code": "KMU",
          "value": 'Kismayo, SOMALIA (KMU)',
        },
        {
          "name": 'Garowe',
          "code": "GGR",
          "value": 'Garowe, SOMALIA (GGR)',
        },
        {
          "name": 'Dhuusamarreeb',
          "code": "DSM",
          "value": 'Dhuusamarreeb, SOMALIA (DSM)',
        }
      ]
    },
    {
      "name": 'Asia',
      "value": [
        {
          "name": 'Hong Kong',
          "code": "HKG",
          "value": 'Hong Kong, HONG KONG (HKG)',
        },
        {
          "name": 'Taipei',
          "code": "TPE",
          "value": 'Taipei, TAIWAN (TPE)',
        },
        {
          "name": 'Shanghai',
          "code": "SHA",
          "value": 'Shanghai, CHINA (SHA)',
        },
        {
          "name": 'Tokyo',
          "code": "HND",
          "value": 'Tokyo, JAPAN (HND)',
        },
        {
          "name": 'Seoul',
          "code": "GMP",
          "value": 'Seoul, SOUTH KOREA (GMP)',
        },
        {
          "name": 'Bangkok',
          "code": "BKK",
          "value": 'Bangkok, THAILAND (BKK)',
        },
        {
          "name": 'Singapore',
          "code": "SIN",
          "value": 'Singapore, SINGAPORE (SIN)',
        },
        {
          "name": 'Manila',
          "code": "MNL",
          "value": 'Manila, PHILIPPINES (MNL)',
        }
      ],
    },
    {
      "name": 'Europe',
      "value": [
        {
          "name": 'London',
          "code": "LHR",
          "value": 'London, UNITED KINGDOM (LHR)',
        },
        {
          "name": 'Frankfurt',
          "code": "FRA",
          "value": 'Frankfurt, GERMANY (FRA)',
        },
        {
          "name": 'Rome',
          "code": "RME",
          "value": 'Rome, UNITED STATES (RME)',
        },
        {
          "name": 'Paris',
          "code": "CDG",
          "value": 'Paris, FRANCE (CDG)',
        },
        {
          "name": 'Amsterdam',
          "code": "AMS",
          "value": 'Amsterdam, THE NETHERLANDS (AMS)',
        },
        {
          "name": 'Madrid',
          "code": "MAD",
          "value": 'Madrid, SPAIN (MAD)',
        },
      ],
    },
    {
      "name": 'North-America',
      "value": [
        {
          "name": 'New York',
          "code": "JFK",
          "value": 'New York, UNITED STATES (JFK)',
        },
        {
          "name": 'San Francisco',
          "code": "SFO",
          "value": 'San Francisco, UNITED STATES (SFO)',
        },
        {
          "name": 'Los Angeles',
          "code": "LAX",
          "value": 'Los Angeles, UNITED STATES (LAX)',
        },
        {
          "name": 'Chicago',
          "code": "ORD",
          "value": 'Chicago, UNITED STATES (ORD)',
        },
        {
          "name": 'Vancouver',
          "code": "CXH",
          "value": 'Vancouver, CANADA (CXH)',
        },
        {
          "name": 'Toronto',
          "code": "YTO",
          "value": 'Toronto, CANADA (YTO)',
        },
      ],
    }
  ];
}
