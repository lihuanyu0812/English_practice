import { env } from '../config/env.js';
import { httpError } from '../utils/httpError.js';

function extractResponseText(data) {
  if (typeof data.output_text === 'string') return data.output_text;
  const textParts = [];
  for (const item of data.output || []) {
    for (const content of item.content || []) {
      if (content.type === 'output_text' && typeof content.text === 'string') {
        textParts.push(content.text);
      }
    }
  }
  return textParts.join('\n');
}

export async function judgeMeaning({ articleEnglishText, targetWord, translation, userInput }) {
  if (!env.openai.apiKey || env.openai.apiKey === 'your_openai_api_key') {
    throw httpError(500, '缺少 OPENAI_API_KEY，无法完成非精确答案判定');
  }

  const response = await fetch('https://api.openai.com/v1/responses', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${env.openai.apiKey}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      model: env.openai.model,
      input: [
        {
          role: 'system',
          content: [
            {
              type: 'input_text',
              text: '你是英语练习系统的判题器。只判断用户输入是否与目标英文单词含义接近但不适用于当前英文上下文，或完全错误。'
            }
          ]
        },
        {
          role: 'user',
          content: [
            {
              type: 'input_text',
              text: JSON.stringify({
                articleEnglishText,
                targetWord,
                targetChineseMeaning: translation,
                userInput
              })
            }
          ]
        }
      ],
      text: {
        format: {
          type: 'json_schema',
          name: 'word_judgement',
          strict: true,
          schema: {
            type: 'object',
            additionalProperties: false,
            properties: {
              result_status: {
                type: 'string',
                enum: ['meaning_correct_but_not_applicable', 'incorrect']
              },
              reason: {
                type: 'string'
              }
            },
            required: ['result_status', 'reason']
          }
        }
      }
    })
  });

  if (!response.ok) {
    const detail = await response.text();
    throw httpError(500, `OpenAI 判定失败：${detail}`, 'OpenAI 判定失败，无法生成练习统计');
  }

  const data = await response.json();
  const text = extractResponseText(data);
  try {
    const parsed = JSON.parse(text);
    return {
      resultStatus: parsed.result_status,
      reason: parsed.reason
    };
  } catch (error) {
    throw httpError(500, `OpenAI 返回内容不是合法 JSON：${text}`, 'OpenAI 判定结果解析失败');
  }
}
