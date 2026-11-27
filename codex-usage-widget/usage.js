function readUsage(text) {
  const lines = text.normalize('NFKC').split(/\n/).map(line => line.trim()).filter(Boolean);
  const fiveHours = /(?:\b5[ -]hours?\b|5\s*時間)/i;
  const creditBalance = /^(?:(?:available|remaining) credits|credits (?:remaining|balance|available)|credit balance|(?:残り|利用可能な)クレジット|クレジット(?:残高|の残り|の残高))/i;
  const nextSection = /(?:\bweekly\b|\bweek\b|\bmonthly\b|\b7[ -]days?\b|週間|週次|月間|使用履歴|usage history)/i;
  let percent = null;
  let credits = null;

  for (const [index, line] of lines.entries()) {
    if (fiveHours.test(line)) {
      const section = [line];
      for (const candidate of lines.slice(index + 1, index + 5)) {
        if (nextSection.test(candidate) || creditBalance.test(candidate)) break;
        section.push(candidate);
      }
      const value = section.join(' ').match(/(\d{1,3})\s*%/);
      if (value && Number(value[1]) <= 100) {
        const surrounding = section.join(' ').replace(fiveHours, '');
        const used = /%\s*(?:used|使用済み?|消費済み?)|(?:\bused\b|使用済み?|消費済み?)\s*[:：]?\s*\d+\s*%/i;
        percent = used.test(surrounding) ? 100 - Number(value[1]) : Number(value[1]);
      }
    }

    if (creditBalance.test(line)) {
      const suffix = line.replace(creditBalance, '').replace(/^\s*[:：]?\s*/, '');
      const amount = (suffix || lines[index + 1] || '').match(/^([\d,]+(?:\.\d+)?)(?:\s*(?:credits?|クレジット))?$/i);
      if (amount && /^\d+(?:,\d{3})*(?:\.\d+)?$/.test(amount[1])) credits = amount[1];
    }
  }

  return { percent, credits };
}

if (typeof module !== 'undefined') module.exports = readUsage;
