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
Talk Format
What attendees will make
Background Info
Tools/Resources
Availability
Frequency
Tech
Equipment Needed
Video Link
!.split("\n")

i = {}
fields.each.with_index do |f,idx|
  i[f] = idx
end

p i

custom = %!Programming Experience
Current Status
Underrepresented Group
Community Involvement
CodeNewbie Involvement
Code Goals
Need
LinkedIn
Twitter
Other Details
Subscribe to Newsletter
!.split("\n")

ev = Event.last

proposals = CSV.parse ARGF.read

header = proposals.shift

proposals.each do |pr|
  next if ev.proposals.where(title: pr[i['Name']]).count > 0

  sf = ev.session_formats.find_by_name("Person")

  obj = ev.proposals.create({
    title: pr[i['Name']],
    details: "None",
    pitch: "None",
    abstract: "None",
    track: ev.tracks.find_by_name(pr[i['Track']]),
    session_format: sf,
  })

  cf = {}
  custom.each do |c|
    cf[c] = pr[i[c]].to_s
  end

  obj.custom_fields = cf

  obj.save!

  obj.speakers.create({
    event: ev,
    speaker_name: pr[i['Legal Name']],
    speaker_email: pr[i['Email Address']],
    bio: pr[i['Traveling from']].to_s + "\n\n" + pr[i['Travel Needs']].to_s + "\n\n" + pr[i['Referrer']].to_s
  }).save!

  puts obj.title
end
