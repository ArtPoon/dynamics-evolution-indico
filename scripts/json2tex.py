import json
import argparse

preamble = """\\documentclass[12pt]{book}

\\usepackage{fullpage}
\\usepackage{times}

\\usepackage{titlesec}
\\titleformat{\chapter}[display]
{\\normalfont\\Large\\filcenter\\sffamily}{}{1pc}{\\Huge}
[\\titlerule\\vspace*{\\fill}\\newpage]

\\setlength\\parindent{0pt}
\\setlength\\parskip{6pt}

\\begin{document}
"""


def parse_authors(abstract):
    """
    :param abstract: dict, JSON entry for one abstract
    :return: formatted strings for authors and affiliations
    """
    aut = abstract["persons"]
    
    # collect unique affiliations
    affils = []
    for a in aut:
        affil = clean_tex(a["affiliation"])
        if affil not in affils:
            affils.append(affil)
    
    astr = ""
    for i in range(len(aut)):
        if len(aut) > 1 and i > 0:
            if i < len(aut)-1:
                astr += ', '
            else:
                astr += " and "  # separator for last author
        a = aut[i]
        if a["is_speaker"]:
            astr += "*"  # presenting author

        given_name = f"{a['first_name']} {a['last_name']}"
        astr += clean_tex(given_name)
        # TODO: JSON does not store multiple affiliations
        affi = affils.index(clean_tex(a["affiliation"]))
        astr += f"$^{ {affi+1} }$"

    return astr, affils


def clean_tex(tex, escape="_%&@", replace=(
        ("$6", "\\$6"), ("O(N^2)", "$O(N^2)$"),
        (u'β', '$\\beta$'), (u'≈', '$\\approx$'), (u'π', '$\\pi$'),
        (u'≥', '$\\ge$'), (u'“', '``'), (u'”', "''"), (u'−', '-'),
        (u'≤', '$\\le$'), (u' ', ' '), (u' ', ' '), (u'₀', '$_0$'),
        (u'×', '$\\times$'), (u'ˉ', '-'), (u'á', "\\'a"), (u'í', "\\'i"),
        (u'é', "\\'e"), ("<", "$<$"), (u"", "-"), (u'γ', '$\\gamma$'),
        (u'α', '$\\alpha$'), (u' ', ''), (u'χ²', '$\\chi^2$'),
        (u'²', '$^2$')
)):
    """
    Add escapes for special characters "_", "%", "&".
    Replace common Unicode characters with TeX equivalent.
    :param tex: str, plain text to process
    :return:
    """
    for chr in escape:
        tex = tex.replace(chr, f"\\{chr}")
    for chr, repl in replace:
        tex = tex.replace(chr, repl)
    return tex


def append_tex(a, outstr):
    title = clean_tex(a['title']).upper()
    outstr += f"{a['friendly_id']}. {title}\n\n"
    astr, affils = parse_authors(a)
    outstr += astr + '\n\n'
    for i, affil in enumerate(affils):
        outstr += f"$^{ {i + 1} } $ {affil}\\\\\n"
    outstr += "\n"
    outstr += clean_tex(a["content"])
    outstr += '\n\n\\clearpage\n\n'
    return outstr


def json2tex(obj):
    """
    Convert JSON entries into a TeX document
    :param obj:
    :return:
    """
    outstr = preamble

    abstracts = obj["abstracts"]
    # exclude rejected abstracts
    accepted = [a for a in abstracts if a["state"] == "accepted"]

    # separate oral and poster abstracts
    orals, posters = [], []
    for a in accepted:
        if a["accepted_contrib_type"]["name"] == "Oral":
            orals.append(a)
        else:
            posters.append(a)

    # output oral abstracts first
    outstr += "\\chapter{Oral abstracts}\n"
    for a in orals:
        outstr = append_tex(a, outstr)

    # output poster abstracts next
    outstr += "\\chapter{Poster abstracts}\n"
    for a in posters:
        outstr = append_tex(a, outstr)

    outstr += "\\end{document}\n"
    return outstr


if __name__ == "__main__":
    parser = argparse.ArgumentParser("Convert Indico JSON to TeX")
    parser.add_argument("infile", type=argparse.FileType('r'),
                        help="input JSON")
    parser.add_argument("outfile", type=argparse.FileType('w'),
                        help="output TeX")
    args = parser.parse_args()
    obj = json.load(args.infile)
    tex = json2tex(obj)
    args.outfile.write(tex)
