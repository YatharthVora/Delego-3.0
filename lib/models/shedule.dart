class Schedule {
  final String? id;
  final String? name;
  final String? location;
  final String? time;
  final String? description;
  final String? image;

  const Schedule({
    this.id,
    this.name,
    this.location,
    this.time,
    this.description,
    this.image,
  });
}

List<Schedule> schedules = [
  const Schedule(
    id: "1",
    name: "Registrations",
    location: "MPSTME",
    time: "9:30 - 11:00AM",
    description:
        "The delegates and the executive board members first proceed for registrations as we commence for the first day of Mumbai MUN 2023.",
    image: "assets/img/reg.jpg",
  ),
  const Schedule(
    id: "2",
    name: "Opening Ceremony",
    location: "Big Seminar Hall",
    time: "11:00 - 12:30PM",
    description:
        "The opening ceremony marks the start of the ninth installment of this resplendent Conference.The distinguished Secretariat delivers keynote addresses to set the underlying tone and summarize the core message for the event coupled with a panel discussion from our illustrious guest speakers who will engage the audience in a comprehensive dialogue.",
    image: "assets/img/ceremony.jpg",
  ),
  const Schedule(
    id: "3",
    name: "Lunch",
    location: "Canteen",
    time: "12:30 - 02:00PM",
    description:
        "Delight your palate by feasting on the splendid meals provided by our organizing committee which is customary in maintaining our long standing tradition of delivering unmatched hospitality and comfort to all our delegates.",
    image: "assets/img/lunch.jpeg",
  ),
  const Schedule(
    id: "4",
    name: "Committee Session 1",
    location: "Allocated Rooms in MPSTME",
    time: "02:00 - 05:00PM",
    description:
        "D-Day is here! Prepare to engage in tantalizing deliberations to establish your stance on the agenda at hand and flaunt your grasp of international diplomacy and verbal flair.",
    image: "assets/img/sessions.jpg",
  ),
  const Schedule(
    id: "5",
    name: "High Tea",
    location: "Canteen",
    time: "05:00 - 05:30PM",
    description:
        "Reinvigorate your mind with a kick of caffeine and luscious snacks to prepare for lobbying with potential allies and foes who will play a decisive role in dissensions to follow.",
    image: "assets/img/hightea.jpg",
  ),
  const Schedule(
    id: "6",
    name: "Formal Socials",
    location: "Big Seminar Hall",
    time: "05:30 - 07:30PM ",
    description:
        "Join us for an evening of entertainment, mingling, and networking at the Formal Socials event. It's a great opportunity to meet fellow students, enjoy some light refreshments, and unwind after a busy week. Whether you're looking to make new friends, catch up with old ones, or just relax, this event has something for everyone.",
    image: "assets/img/socials.jpg",
  ),
  // const Schedule(
  //   id: "7",
  //   name: "MUN - O Ranjan",
  //   location: "Big Seminar Hall",
  //   time: "18:00 - 20:00",
  //   description: "Revel in the pinnacle of diplomatic success after what has been the greatest test of diplomatic powers! The fate of the world hangs in balance, and it all depends on the delegates to alter its course. The paradox of progress is bound to leave its mark, even as the delegates strive to ensure that justice and peace prevails.",
  //   image: "assets/img/socials.jpg",
  // ),
];

// List<Schedule> schedules1 = [
//   const Schedule(
//     id: "1",
//     name: "Breakfast",
//     location: "Canteen",
//     time: "08:00 - 09:00AM",
//     description:
//         "Prepare yourself for a competitive session of debating and lobbying and begin the second day of the conference with a scrumptious serving provided by our organizing committee.",
//     image: "assets/img/lunch.jpeg",
//   ),
//   const Schedule(
//     id: "2",
//     name: "Committee Session 2",
//     location: "Allocated Rooms in MPSTME",
//     time: "09:00AM - 12:00PM",
//     description:
//         "Immerse into your diplomatic demeanor with the commencement of the first session of the day. With your thoughts put on ice, enter into the heat of the debate for the second day.",
//     image: "assets/img/sessions.jpg",
//   ),
//   const Schedule(
//     id: "3",
//     name: "Lunch",
//     location: "Canteen",
//     time: "12:00 - 01:00PM",
//     description:
//         "Delight your palate by feasting on the splendid meals provided by our organizing committee which is customary in maintaining our long standing tradition of delivering unmatched hospitality and comfort to all our delegates.",
//     image: "assets/img/lunch.jpeg",
//   ),
//   const Schedule(
//     id: "4",
//     name: "Committee Session 3",
//     location: "Allocated Rooms in MPSTME",
//     time: "01:00 - 04:00PM",
//     description:
//         "The time utilized by the delegates during lunch determines the propensity of this session. With flare and zeal, this session will emphasize on the solutions to address the agenda of the committee.",
//     image: "assets/img/sessions.jpg",
//   ),
//   const Schedule(
//     id: "5",
//     name: "High Tea",
//     location: "Canteen",
//     time: "04:00 - 05:30PM",
//     description:
//         "Reinvigorate your mind with a kick of caffeine and luscious snacks to prepare for lobbying with potential allies and foes who will play a decisive role in dissensions to follow.",
//     image: "assets/img/hightea.jpg",
//   ),
//   // const Schedule(
//   //   id: "6",
//   //   name: "The Mumbai Experience",
//   //   location: "SVKM's Shri Bhagubhai Mafatlal Polytechnic",
//   //   time: "05:30PM Onwards",
//   //   description:
//   //       "This session will be a crucial juncture for you. The blocs formed in the committee are discernible at this point of time. The session marks the budding of the paperwork from the delegates for a resolution/ press release from the committee. Pragmatically approach the scenario in the committee and end the day on a high note.",
//   //   image: "assets/img/socials.jpg",
//   // ),
// ];
//
// List<Schedule> schedules2 = [
//   const Schedule(
//     id: "1",
//     name: "Breakfast",
//     location: "Canteen",
//     time: "08:00 - 09:00AM",
//     description:
//         "With yet another day of intense diplomacy to look forward to, a hearty breakfast is a must! So, eat some breakfast and get ready to change the world!",
//     image: "assets/img/lunch.jpeg",
//   ),
//   const Schedule(
//     id: "2",
//     name: "Committee Session 4",
//     location: "Allocated Rooms in MPSTME",
//     time: "09:00 - 12:00PM",
//     description:
//         "After two days of intense debate, the moment of truth is finally here. Dot the I’s and cross the T’s as delegates across all committees strive to ensure that their agenda is taken care of, as tough negotiations ensue.",
//     image: "assets/img/sessions.jpg",
//   ),
//   const Schedule(
//     id: "3",
//     name: "Lunch",
//     location: "Canteen",
//     time: "12:00 - 01:00PM",
//     description:
//         "Indulge in a delectable lunch, with last-minute lobbying that can make or break days worth of deliberation. But in all the frantic discussions and pursuing last-minute votes, do not forget to treat your palate to the epitome of culinary excellence. Bon Appétit!",
//     image: "assets/img/lunch.jpeg",
//   ),
//   const Schedule(
//     id: "4",
//     name: "Committee Session 5",
//     location: "Allocated Rooms in MPSTME",
//     time: "01:00 - 04:00PM",
//     description:
//         "Revel in the pinnacle of diplomatic success after what has been the greatest test of diplomatic powers! The fate of the world hangs in balance, and it all depends on the delegates to alter its course. The paradox of progress is bound to leave its mark, even as the delegates strive to ensure that justice and peace prevails.",
//     image: "assets/img/sessions.jpg",
//   ),
//   const Schedule(
//     id: "5",
//     name: "High Tea",
//     location: "Canteen",
//     time: "04:00 - 05:00PM",
//     description:
//         "Reinvigorate your mind with a kick of caffeine and luscious snacks to prepare for lobbying with potential allies and foes who will play a decisive role in dissensions to follow.",
//     image: "assets/img/hightea.jpg",
//   ),
//   const Schedule(
//     id: "6",
//     name: "Closing Ceremony",
//     location: "Big Seminar Hall",
//     time: "05:00 - 07:30PM",
//     description:
//         "The time has come to bid adieu to what has hopefully been an enchanting experience, here at Mumbai MUN 2024. Participate in an elegant ceremony that not only celebrates the best diplomatic skills across all committees but also the alluring spirit of diplomacy!",
//     image: "assets/img/ceremony.jpg",
//   ),
// ];
