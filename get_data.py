#!/usr/bin/env python3

import re
import sys

import requests
from tqdm import tqdm


def compute_similarity(a, b):
    if a == b:
        return 1
    similarity = 0
    weight = 1 / 2
    for x, y in zip(a.lower()[::-1], b.lower()[::-1]):
        if x == y:
            similarity += weight
        weight /= 2
    return similarity


def get_most_similar_index(lst, x):
    similarities = [compute_similarity(y, x) for y in lst]
    sindex = similarities.index(max(similarities))
    return sindex


def find_common_base(lst):
    if not lst:
        return ''
    base = ''
    for i in range(len(min(lst, key=len))):
        chars = set([x[i] for x in lst])
        if len(chars) != 1:
            return base
        base += lst[0][i]
    return base


def request_wiki(name):
    response = requests.get('https://cs.wiktionary.org/wiki/' + name)
    content = re.sub(r'\s+', '', response.content.decode('utf-8'))
    table = re.findall(r'<tableclass="deklinacesubstantivum">(.*?)<\/table>', content)
    if table:
        entities = re.findall(r'<td>(.*?)<\/td>', table[0])
        if len(entities) != 14:
            return list()
        e_pattern = r'<[^>]*?>([\w\/]+?)<\/[^>]*>'
        for i in range(len(entities)):
            found_e = re.findall(e_pattern, entities[i])
            if found_e:
                found_e = found_e[0]
            else:
                found_e = entities[i]
            entities[i] = found_e.split('/', 1)[0].split('<', 1)[0]
            entities[i] = name if entities[i] == '—' or not entities[i].strip() else entities[i]
        reorg_entities = list()
        for i in range(14):
            reorg_entities.append(entities[(i // 7 + 2 * i) % 14])
        return reorg_entities
    return list()


def request_sklonuj(name):
    response = requests.get('https://sklonuj.cz/jmeno/' + name)
    content = re.sub(r'\s+', '', response.content.decode('utf-8'))
    table = re.findall(r'<ulclass=\"list-group[^\"]*?\">(.*?)<\/ul>', content)
    if table:
        return re.findall(r'<liclass=\"list-group-item\">(.*?)<\/li>', table[0])
    return list()


def get_declension(name):
    entities = [name for _ in range(14)]
    base = ''
    rw = request_wiki(name)
    if rw and len(rw) == 14:
        entities = rw
    else:
        rs = request_sklonuj(name)
        if rs and len(rs) == 14:
            entities = rs
    base = find_common_base(entities)
    entities = ["_" if not x[len(base):] else x[len(base):] for x in entities]
    return entities


def get_all_declensions(input_file, output_filename):
    groups = list()
    names = list()

    data = list()
    with open(input_file, 'r', encoding='UTF-8') as rf:
        data = rf.readlines()
    for line in tqdm(data):
        name = line.strip()
        if name:
            decl = get_declension(name)
            if decl in groups:
                names[groups.index(decl)].append(name)
            else:
                groups.append(decl)
                names.append([name])

    with open(output_filename + '.names', 'w', encoding='UTF-8') as wf:
        for i in range(len(names)):
            for name in names[i]:
                wf.write('{0},{1}\n'.format(name, i + 1))

    with open(output_filename + '.decl', 'w', encoding='UTF-8') as wf:
        for group in groups:
            wf.write('{0}\n'.format(','.join(group)))


def find_declension(data_filename, name):
    names = list()
    groups = list()
    with open(data_filename + '.names', 'r', encoding='UTF-8') as rf:
        for line in rf.readlines():
            if line.strip():
                n, g = line.strip().split(',')
                names.append(n)
                groups.append(g)

    name_index = get_most_similar_index(names, name)
    print(names[name_index], ':', name)

    with open(data_filename + '.decl', 'r', encoding='UTF-8') as rf:
        rules = rf.readlines()
        print(rules[int(groups[name_index])])


if __name__ == '__main__':
    get_all_declensions(sys.argv[1], sys.argv[2])
