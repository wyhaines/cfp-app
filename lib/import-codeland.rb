require 'csv'

fields = %!Name,Legal Name,Email Address,Track,Programming Experience,Current Status,Underrepresented Group,Community Involvement,CodeNewbie Involvement,Code Goals,Need,LinkedIn,Twitter,Other Details,Subscribe to Newsletter,Travel Needs,Traveling from,Referrer!.split(",")

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

p ev

proposals = CSV.parse ARGF.read

header = proposals.shift

proposals.each do |pr|
  next if ev.proposals.where(title: pr[i['Name']]).count > 0

  sf = ev.session_formats.find_by_name("Person")

  obj = ev.proposals.find_by_title(pr[i['Name']])
  add_speaker = true
  if obj
    obj.track = ev.tracks.find_by_name(pr[i['Track']])
    add_speaker = false
  else
    obj = ev.proposals.create({
      title: pr[i['Name']],
      details: "None",
      pitch: "None",
      abstract: "None",
      track: ev.tracks.find_by_name(pr[i['Track']]),
      session_format: sf,
    })
  end

  cf = {}
  custom.each do |c|
    cf[c] = pr[i[c]].to_s
  end

  obj.custom_fields = cf

  obj.save!

  if add_speaker
    obj.speakers.create({
      event: ev,
      speaker_name: pr[i['Legal Name']] || pr[i['Name']],
      speaker_email: pr[i['Email Address']] || 'none@none.com',
      bio: pr[i['Traveling from']].to_s + "\n\n" + pr[i['Travel Needs']].to_s + "\n\n" + pr[i['Referrer']].to_s
    }).save!
  end

  puts obj.title
end
