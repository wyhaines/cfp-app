require 'csv'

fields = %!Name - S
Speaker Name
Email - S
Speaker Bio
LinkedIn
Twitter
Gender
Ethnicity
Ethnicity - Other
Bio.1 - S
Speaker Background
Coding Status
Coding Status - Other
Coding Background
Coding Background - Other
Talk Topic
Talk Topic - Other
Title - S
Talk Elements
Talk Elements - Other
Details - S
Problem
Takeaway
Intention
Research
Pitch - S
Other Details
Bio.2 - S
Talk Length
Track - S
!.split("\n")

i = {}
fields.each.with_index do |f,idx|
  i[f] = idx
end

p i

custom = %!Speaker Name
Speaker Bio
LinkedIn
Twitter
Gender
Ethnicity
Ethnicity - Other
Speaker Background
Coding Status
Coding Status - Other
Coding Background
Coding Background - Other
Talk Topic
Talk Topic - Other
Talk Elements
Talk Elements - Other
Problem
Takeaway
Intention
Research
Other Details
Talk Length
!.split("\n")

ev = Event.last

proposals = CSV.parse ARGF.read

header = proposals.shift

sf = ev.session_formats.last

proposals.each do |pr|
  obj = ev.proposals.create({
    title: pr[i['Title - S']],
    details: pr[i['Details - S']],
    pitch: pr[i['Pitch - S']],
    abstract: "unused",
    track: ev.tracks.find_by_name(pr[i['Track - S']]),
    session_format: sf,
  })

  cf = {}
  custom.each do |c|
    cf[c] = pr[i[c]]
  end

  obj.custom_fields = cf

  obj.save!

  obj.speakers.create({
    speaker_name: pr[i['Name - S']],
    speaker_email: pr[i['Email - S']],
    bio: pr[i['Bio.1 - S']].to_s + "\n" + pr[i['Bio.2 - S']].to_s,
  })

  puts obj.title
end
