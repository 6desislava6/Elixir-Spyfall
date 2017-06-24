alias SpyfallServer.Repo
alias SpyfallServer.Actor

#actors
locations = [["first class passenger",
  "air marshall",
  "mechanic",
  "air hostess",
  "copilot",
  "captain",
  "economy class passenger"
], [
  "armored car driver",
  "manager",
  "consultant",
  "robber",
  "security guard",
  "teller",
  "customer"
], [
  "beach waitress",
  "kite surfer",
  "lifeguard",
  "thief",
  "beach photographer",
  "ice cream truck driver",
  "beach goer"
], [
  "priest",
  "beggar",
  "sinner",
  "tourist",
  "sponsor",
  "chorister",
  "parishioner"
], [
  "acrobat",
  "animal trainer",
  "magician",
  "fire eater",
  "clown",
  "juggler",
  "visitor"
], [
  "entertainer",
  "manager",
  "unwanted guest",
  "owner",
  "secretary",
  "delivery boy",
  "accountant"
], [
  "monk",
  "imprisoned saracen",
  "servant",
  "bishop",
  "squire",
  "archer",
  "knight"
], [
  "bartender",
  "head security guard",
  "bouncer",
  "manager",
  "hustler",
  "dealer",
  "gambler"
], [
  "stylist",
  "masseuse",
  "manicurist",
  "makeup artist",
  "dermatologist",
  "beautician",
  "customer"
], [
  "security guard",
  "secretary",
  "ambassador",
  "tourist",
  "refugee",
  "diplomat",
  "government official"
], [
  "nurse",
  "doctor",
  "anesthesiologist",
  "intern",
  "therapist",
  "surgeon",
  "patient"
], [
  "doorman",
  "security guard",
  "manager",
  "housekeeper",
  "bartender",
  "bellman",
  "customer"
], [
  "deserter",
  "colonel",
  "medic",
  "sniper",
  "officer",
  "tank engineer",
  "soldier"
], [
  "stunt man",
  "sound engineer",
  "camera man",
  "director",
  "costume artist",
  "producer",
  "actor"
], [
  "cook",
  "captain",
  "bartender",
  "musician",
  "waiter",
  "mechanic",
  "rich passenger"
], [
  "mechanic",
  "border patrol",
  "train attendant",
  "restaurant chef",
  "train driver",
  "stoker",
  "passenger"
], [
  "cook",
  "slave",
  "cannoneer",
  "tied up prisoner",
  "cabin boy",
  "brave captain",
  "sailor"
], [
  "medic",
  "expedition leader",
  "biologist",
  "radioman",
  "hydrologist",
  "meteorologist",
  "geologist"
], [
  "detective",
  "lawyer",
  "journalist",
  "criminalist",
  "archivist",
  "criminal",
  "patrol officer"
], [
  "musician",
  "bouncer",
  "hostess",
  "head chef",
  "food critic",
  "waiter",
  "customer"
], [
  "gym teacher",
  "principal",
  "security guard",
  "janitor",
  "cafeteria lady",
  "maintenance man",
  "student"
], [
  "manager",
  "tire specialist",
  "biker",
  "car owner",
  "car wash operator",
  "electrician",
  "auto mechanic"
], [
  "engineer",
  "alien",
  "pilot",
  "commander",
  "scientist",
  "doctor",
  "space tourist"
], [
  "cook",
  "commander",
  "sonar technician",
  "electronics technician",
  "radioman",
  "navigator",
  "sailor"
], [
  "cashier",
  "butcher",
  "janitor",
  "security guard",
  "food sample demonstrator",
  "shelf stocker",
  "customer"
], [
  "coat check lady",
  "prompter",
  "cashier",
  "director",
  "actor",
  "crew man",
  "audience member"
], [
  "graduate student",
  "professor",
  "dean",
  "psychologist",
  "maintenance man",
  "janitor",
  "student"
], [
  "resistance fighter",
  "radioman",
  "scout",
  "medic",
  "cook",
  "imprisoned nazi",
  "soldier"
]]

Enum.with_index(locations) |> Enum.each(fn {actors, location_id} ->
  Enum.each(actors, fn actor -> Repo.insert! %Actor{name: actor, location_id: (location_id + 1)} end)
end)
