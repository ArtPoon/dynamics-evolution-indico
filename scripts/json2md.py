import json

def join_authors(abstract):
    aut = abstract["persons"]
    
    # collect affiliations
    affils = []
    for a in aut:
        affil = a["affiliation"]
        if affil not in affils:
            affils.append(affil)
    
    outstr = ""
    for i in range(len(aut)):
        if len(aut) > 1 and i == len(aut)-1:
            outstr += " and "
            
        a = aut[i]
        if a["is_speaker"]:
            outstr += "*"  # presenting author
        
        # given name
        outstr += f"a['first_name'] a['last_name']"
        
        affi = affils.index(a["affiliation"])
        outstr += f"<sup>{affi}</sup>"
        

db = json.load(open("accepted.json"))
abstracts = db["abstracts"]

# exclude rejected abstracts
accepted = [a for a in abstracts if a["state"] == "accepted"]

orals = [a for a in accepted if a["accepted_contrib_type"]["name"] == "Oral"]
posters = [a for a in accepted if a["accepted_contrib_type"]["name"] == "Poster"]

print("#Orals")
print("---")

for a in orals:
    print(f"{a['friendly_id']}. {a['title'].upper()}")
    
    print("\n---\n")
