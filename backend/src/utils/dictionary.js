import { httpError } from './httpError.js';

const PART_OF_SPEECH_PATTERN =
  /^\s*((?:abbr|adj|adv|ad|art|aux|conj|det|int|interj|modal|num|prep|pron|vi|vt|v|a|n|c|u|pl)\.?(?:\s*\/\s*(?:abbr|adj|adv|ad|art|aux|conj|det|int|interj|modal|num|prep|pron|vi|vt|v|a|n|c|u|pl)\.?)*)/i;

export function withDictionaryInfo(row) {
  const translation = row.dictionary_translation || '';
  const match = translation.match(PART_OF_SPEECH_PATTERN);
  const {
    dictionary_word: _dictionaryWord,
    dictionary_translation: _dictionaryTranslation,
    lookup_word: _lookupWord,
    pos,
    ...rest
  } = row;
  return {
    ...rest,
    phonetic: row.phonetic || '',
    part_of_speech: pos || (match ? match[1] : ''),
    translation
  };
}

export function assertDictionaryInfo(rows) {
  const missingWords = rows
    .filter((row) => !row.dictionary_word)
    .map((row) => row.target_word);

  if (missingWords.length) {
    throw httpError(500, `词典库缺少单词数据：${[...new Set(missingWords)].join(', ')}`);
  }
}
