const fs = require("fs");
const zlib = require("zlib");

const font = {
  " ": ["00000","00000","00000","00000","00000","00000","00000"],
  A: ["01110","10001","10001","11111","10001","10001","10001"],
  C: ["01111","10000","10000","10000","10000","10000","01111"],
  D: ["11110","10001","10001","10001","10001","10001","11110"],
  E: ["11111","10000","10000","11110","10000","10000","11111"],
  G: ["01111","10000","10000","10111","10001","10001","01111"],
  H: ["10001","10001","10001","11111","10001","10001","10001"],
  I: ["11111","00100","00100","00100","00100","00100","11111"],
  L: ["10000","10000","10000","10000","10000","10000","11111"],
  M: ["10001","11011","10101","10101","10001","10001","10001"],
  N: ["10001","11001","10101","10011","10001","10001","10001"],
  O: ["01110","10001","10001","10001","10001","10001","01110"],
  P: ["11110","10001","10001","11110","10000","10000","10000"],
  R: ["11110","10001","10001","11110","10100","10010","10001"],
  S: ["01111","10000","10000","01110","00001","00001","11110"],
  T: ["11111","00100","00100","00100","00100","00100","00100"],
  U: ["10001","10001","10001","10001","10001","10001","01110"],
  X: ["10001","10001","01010","00100","01010","10001","10001"],
  Y: ["10001","10001","01010","00100","00100","00100","00100"],
  Z: ["11111","00001","00010","00100","01000","10000","11111"],
  "0": ["01110","10001","10011","10101","11001","10001","01110"],
  "1": ["00100","01100","00100","00100","00100","00100","01110"],
  "2": ["01110","10001","00001","00010","00100","01000","11111"],
  "5": ["11111","10000","11110","00001","00001","10001","01110"],
  "6": ["00110","01000","10000","11110","10001","10001","01110"],
  ":": ["00000","00100","00100","00000","00100","00100","00000"],
};

function crc32(buf) {
  let c = ~0;
  for (let i = 0; i < buf.length; i++) {
    c ^= buf[i];
    for (let k = 0; k < 8; k++) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
  }
  return ~c >>> 0;
}

function chunk(type, data) {
  const t = Buffer.from(type);
  const out = Buffer.alloc(12 + data.length);
  out.writeUInt32BE(data.length, 0);
  t.copy(out, 4);
  data.copy(out, 8);
  out.writeUInt32BE(crc32(Buffer.concat([t, data])), 8 + data.length);
  return out;
}

function image(w, h, bg = [0, 0, 0, 255]) {
  const p = Buffer.alloc(w * h * 4);
  for (let i = 0; i < w * h; i++) p.set(bg, i * 4);
  return { w, h, p };
}

function px(img, x, y, c) {
  if (x < 0 || y < 0 || x >= img.w || y >= img.h) return;
  img.p.set(c, (Math.floor(y) * img.w + Math.floor(x)) * 4);
}

function circle(img, cx, cy, r, c) {
  const r2 = r * r;
  for (let y = cy - r; y <= cy + r; y++) {
    for (let x = cx - r; x <= cx + r; x++) {
      if ((x - cx) ** 2 + (y - cy) ** 2 <= r2) px(img, x, y, c);
    }
  }
}

function ring(img, cx, cy, r, c) {
  for (let a = 0; a < Math.PI * 2; a += 0.002) {
    for (let t = -2; t <= 2; t++) px(img, cx + Math.cos(a) * (r + t), cy + Math.sin(a) * (r + t), c);
  }
}

function rect(img, x, y, w, h, c) {
  for (let yy = y; yy < y + h; yy++) for (let xx = x; xx < x + w; xx++) px(img, xx, yy, c);
}

function textWidth(s, scale) {
  return s.length * 6 * scale - scale;
}

function text(img, s, x, y, scale, c) {
  s = s.toUpperCase();
  for (let i = 0; i < s.length; i++) {
    const glyph = font[s[i]] || font[" "];
    for (let gy = 0; gy < 7; gy++) {
      for (let gx = 0; gx < 5; gx++) {
        if (glyph[gy][gx] === "1") rect(img, x + i * 6 * scale + gx * scale, y + gy * scale, scale, scale, c);
      }
    }
  }
}

function centerText(img, s, y, scale, c) {
  text(img, s, Math.round((img.w - textWidth(s, scale)) / 2), y, scale, c);
}

function line(img, x1, x2, y, c) {
  for (let x = x1; x <= x2; x++) px(img, x, y, c);
}

function save(img, path) {
  const rows = Buffer.alloc((img.w * 4 + 1) * img.h);
  for (let y = 0; y < img.h; y++) {
    rows[y * (img.w * 4 + 1)] = 0;
    img.p.copy(rows, y * (img.w * 4 + 1) + 1, y * img.w * 4, (y + 1) * img.w * 4);
  }
  const header = Buffer.alloc(13);
  header.writeUInt32BE(img.w, 0);
  header.writeUInt32BE(img.h, 4);
  header[8] = 8;
  header[9] = 6;
  fs.writeFileSync(path, Buffer.concat([
    Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]),
    chunk("IHDR", header),
    chunk("IDAT", zlib.deflateSync(rows, { level: 9 })),
    chunk("IEND", Buffer.alloc(0)),
  ]));
}

function drawCommon(img, watchR) {
  const green = [49, 208, 123, 255];
  const white = [248, 248, 248, 255];
  const gray = [176, 184, 180, 255];
  const dark = [22, 22, 22, 255];
  const cx = img.w / 2;
  const cy = img.h / 2;
  circle(img, cx, cy, watchR + 24, [10, 10, 10, 255]);
  circle(img, cx, cy, watchR, [0, 0, 0, 255]);
  ring(img, cx, cy, watchR, dark);
  circle(img, cx - 10, cy - watchR + 55, 22, green);
  circle(img, cx + 3, cy - watchR + 52, 22, [0, 0, 0, 255]);
  centerText(img, "NEXT PRAYER", cy - watchR + 104, 3, gray);
  centerText(img, "DHUHR", cy - watchR + 145, 9, green);
  line(img, cx - 80, cx - 12, cy - watchR + 226, [84, 84, 84, 255]);
  line(img, cx + 12, cx + 80, cy - watchR + 226, [84, 84, 84, 255]);
  circle(img, cx, cy - watchR + 226, 5, green);
  centerText(img, "1:05 PM", cy - watchR + 250, 5, white);
  centerText(img, "TODAY", cy - watchR + 294, 3, gray);
  centerText(img, "6H 52M", cy - watchR + 330, 5, white);
  centerText(img, "REMAINING", cy - watchR + 374, 3, gray);
}

const cover = image(500, 500);
drawCommon(cover, 215);
save(cover, "bin/store-cover.png");

const screen = image(500, 500);
drawCommon(screen, 215);
save(screen, "bin/store-screen.png");
