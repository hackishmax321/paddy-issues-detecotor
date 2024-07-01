class ENVConfig {
  // Server Details
  static const String serverUrl = 'https://20dc-112-134-175-32.ngrok-free.app';
  static const String gmap_api = 'AIzaSyDAsJYZSQ92_NQAz9kiSpW1XpyuCxRl_uI';
  static const String weather_api = '3ca1b71cf73d793ea485f6d257cedd49';


  // API Routes
  static const String loginRoute = '/api/login';

  static List<dynamic> pesticidesList = [
    {
      "name": "aphids",
      "title": "Aphids",
      "image": "assets/images/aphids.jpg",
      "instructions": ["Monitor plants regularly and remove infested parts.", "Use insecticidal soap or neem oil as a treatment.", "Encourage natural predators like ladybugs."],
    },
    {
      "name": "armyworm",
      "title": "Armyworm",
      "image": "assets/images/armyworm.jpg",
      "instructions": ["Practice crop rotation to disrupt lifecycle.", "Use pheromone traps to monitor and control populations.", "Apply Bacillus thuringiensis (Bt) as a biological control."],
    },
    {
      "name": "beetle",
      "title": "Beetle",
      "image": "assets/images/beetle.jpg",
      "instructions": ["Handpick beetles and larvae from plants.", "Use row covers to prevent beetles from laying eggs.", "Apply neem oil or insecticidal soap as a treatment."],
    },
    {
      "name": "bollworm",
      "title": "Bollworm",
      "image": "assets/images/bollworm.jpg",
      "instructions": ["Plant resistant varieties of crops.", "Introduce beneficial insects like parasitic wasps.", "Use Bacillus thuringiensis (Bt) as a biological control."],
    },
    {
      "name": "grasshopper",
      "title": "Grasshopper",
      "image": "assets/images/grasshopper.jpg",
      "instructions": ["Keep the area around the field weed-free.", "Use row covers to protect young plants.", "Apply insecticidal baits specifically designed for grasshoppers."],
    },
    {
      "name": "mites",
      "title": "Mites",
      "image": "assets/images/mites.jpg",
      "instructions": ["Maintain proper irrigation to avoid dry conditions.", "Use miticides as a treatment when necessary.", "Encourage natural predators like predatory mites."],
    },
    {
      "name": "mosquito",
      "title": "Mosquito",
      "image": "assets/images/mosquito.jpg",
      "instructions": ["Eliminate standing water around the field.", "Introduce mosquito fish to standing water bodies.", "Use insect repellents and mosquito nets to protect plants."],
    },
    {
      "name": "sawfly",
      "title": "Sawfly",
      "image": "assets/images/sawfly.jpg",
      "instructions": ["Remove and destroy affected leaves manually.", "Use insecticidal soap or neem oil as a treatment.", "Encourage natural predators like birds and beneficial insects."],
    },
    {
      "name": "stem_borer",
      "title": "Stem Borer",
      "image": "assets/images/stem_borer.jpg",
      "instructions": ["Plant resistant varieties of crops.", "Use pheromone traps to monitor and control populations.", "Apply insecticides at the base of the plants during the early stages."],
    },
  ];


}