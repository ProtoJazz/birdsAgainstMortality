# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs

alias BirdsAgainstMortality.{Repo, Cards.Deck}

# Tech/Programming deck
tech_deck_attrs = %{
  white_cards: [
    "Thought leadership","LinkedIn","Growth hacking","The Stanford of Canada","Python","Apache 1.2 running as root","Yet another package manager","Brogrammers","A JAR full of spaghetti","Hacker News","Python datetime module","Functional programming","Golang","Our Release Engineer","Posting on Etsy's codeascraft blog","NullPointerException: null","Rebasing the entire fucking repo","Unknown source in your stack trace","Continuous integration","Degraded performance in some AWS availability zones","MongoDB","OpenSSL","Sysadmins","Command-line magic","Copypasta","NoSQL","Being acquired by Oracle","RecruiterFail","Ruby","NPM","More buzzwords than you can shake a scrum at","Leaky abstractions","Running out of IPv4 addresses","DevOps Days","A GitHub Outage","A former MENSA member","Angular js","The Cult of Mac","Meritocracy","A Cisco router with a flaky chip","Git","DevOps","Node.js","A squirrel with a taste for fiber","Stack trace generator","Web scale","Developers"
  ],
  black_cards: "[{\"draw\":\"0\",\"play\":\"1\",\"text\":\"\\tAsk Me Anything about __________.\"},{\"draw\":\"0\",\"play\":\"1\",\"text\":\"Enterprise __________ in the cloud.\"},{\"draw\":\"0\",\"play\":\"1\",\"text\":\"140 characters is just enough to explain _____.\"},{\"draw\":\"0\",\"play\":\"1\",\"text\":\"Googelure.js\"},{\"draw\":\"0\",\"play\":\"1\",\"text\":\"_____ is for closers.\"},{\"draw\":\"0\",\"play\":\"1\",\"text\":\"_____, as one does.\"},{\"draw\":\"0\",\"play\":\"1\",\"text\":\"Enterprise-ready __________.\"},{\"draw\":\"0\",\"play\":\"1\",\"text\":\"\\t_____ is webscale.\"},{\"draw\":\"0\",\"play\":\"1\",\"text\":\"_____ dooms any project to epic failure.\"},{\"draw\":\"0\",\"play\":\"1\",\"text\":\"\\t_____ or it didn't happen.\"},{\"draw\":\"0\",\"play\":\"1\",\"text\":\"_____ is a feature, not a bug.\"},{\"draw\":\"0\",\"play\":\"1\",\"text\":\"_____ with one weird trick.\"},{\"draw\":\"0\",\"play\":\"1\",\"text\":\"_____ all the way down.\"},{\"draw\":\"0\",\"play\":\"1\",\"text\":\"_____ as a service.\"},{\"draw\":\"0\",\"play\":\"1\",\"text\":\"Called on account of __________.\"},{\"draw\":\"0\",\"play\":\"1\",\"text\":\"Employees must __________ before returning to work.\"}]"
}

# Disney deck
disney_deck_attrs = %{
  white_cards: [
    "Jafar's brow game","A Hawaiian rollercoaster ride","Unexpected musical numbers","Thinking that turning a dog into a coachman is a good idea","Aladdin's hammer pants","All of China knowing you're here","An apple poisoned by a shady bitch","Goofy","Nala's bedroom eyes","A Mickey-shaped pretzel","Planes tho","The Black Cauldron","Not killing a grasshopper because he has some pretty sound advice","Sharing communal underwear because it's part of the uniform","Pooh Bear's honey withdrawals","Marathoning every Disney movie for fifty days straight","Letting your teenage daughter have a pet tiger, but telling her going outside is too dangerous","Pocahontas giving up on men and starting an animal sanctuary with Nakoma","Aurora taking a nap so long that it's technically classified as a coma","Kokuom's bulging biceps","Hosting a dinner party and turning into a llama halfway through","Donald being arrested for not wearing pants","Minnie","Kissing a frog because he asked nicely","Walt Disney himself","Cars with actual eyeballs instead of windshields","Hakuna Matata, bitch","John Lasseter's obsession with cars","101 actual puppies","Tigger learning how to twerk","Being the only one who realizes how weird everyone breaking in to song and dance is","Ariel spending a fortune on hair color","Wendy outstaying her welcome in the nursery","The first five minutes of Up"," MassiveDecks My spinach puffs!","Main Street, USA","Wanting a child so badly that you literally make one","The ethical implications of Mickey owning a dog while also being friends with a walking, talking dog","Tramp","Hairy baby","When your parent just goes and dies for no reason","Shady-ass mermaids","Max Goof's teenage angst","Uppity mothers pushing three-seat strollers around Disneyland","An ugly-ass dress made by mice with good intentions","A prince so thirsty that he marries the first girl he meets"
  ],
  black_cards: "[{\"draw\":\"0\",\"play\":\"1\",\"text\":\"____________ helps  the  medicine  go  down\"},{\"draw\":\"0\",\"play\":\"1\",\"text\":\"In  his  will,  Walt  Disney  left  everything  to _______________\"},{\"draw\":\"0\",\"play\":\"1\",\"text\":\"Help  bring  _________  to  us  all\"},{\"draw\":\"0\",\"play\":\"1\",\"text\":\"_____________   :  Truly  the  greatest  princess\"},{\"draw\":\"0\",\"play\":\"1\",\"text\":\"______________ means  no  worries\"},{\"draw\":\"0\",\"play\":\"1\",\"text\":\"_____________   :  the  next  great  Avenger\"},{\"draw\":\"0\",\"play\":\"1\",\"text\":\"Pull  _____________  ,  Kronk\"},{\"draw\":\"0\",\"play\":\"1\",\"text\":\"Magic  mirror  on  the  wall,  who's  the  trillest  one  of  all?\"},{\"draw\":\"0\",\"play\":\"1\",\"text\":\"Welcome  to  the  Festival  of ___________ !\"},{\"draw\":\"0\",\"play\":\"1\",\"text\":\"When  in  doubt,  _______________\"},{\"draw\":\"0\",\"play\":\"1\",\"text\":\"Contrary  to  popular  belief,  Arthur  actually  pulled ____________  out  of  the  stone\"},{\"draw\":\"0\",\"play\":\"1\",\"text\":\"This  year,  Disney  was  nominated  for  six  Oscars  all  thanks  to _________\"},{\"draw\":\"0\",\"play\":\"1\",\"text\":\"Since  when  is  ___________  a  Disney  Princess?\"},{\"draw\":\"0\",\"play\":\"1\",\"text\":\"MassiveDecks Let  it  go,  let  it  go,  I  am  one  with  __________ !\"},{\"draw\":\"0\",\"play\":\"1\",\"text\":\"When  will  my   _________  show  who  I  am  inside?\"},{\"draw\":\"0\",\"play\":\"1\",\"text\":\"Help  me,  ____________  ,  you're  my  only  hope!\"}]"
}

# Function to create or skip deck based on a unique identifier
create_deck_if_not_exists = fn deck_attrs, identifier ->
  # Use the first white card as a unique identifier
  first_white_card = List.first(deck_attrs.white_cards)

  # Fixed: Get all decks first, then find the one with matching first white card
  existing_deck = Deck
    |> Repo.all()
    |> Enum.find(fn deck ->
      deck.white_cards && List.first(deck.white_cards) == first_white_card
    end)

  case existing_deck do
    nil ->
      IO.puts("Creating deck with identifier: #{identifier}")
      %Deck{}
      |> Deck.changeset(deck_attrs)
      |> Repo.insert!()
    _existing ->
      IO.puts("Deck already exists: #{identifier}")
  end
end

# Create decks
create_deck_if_not_exists.(tech_deck_attrs, "Tech/Programming")
create_deck_if_not_exists.(disney_deck_attrs, "Disney")

IO.puts("Seeds completed!")
