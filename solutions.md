# Solutions

## Part A — Bug tickets

### RES-101 · Search shows results for the wrong query

**Root cause**
- เป็นเพราะว่า ยิ่งจำนวนคำที่ค้นหามากก็ยิ่งได้ข้อมูลเร็วกว่า 

  Repro: `adb shell input text sushi` บนหน้า Search (ยิงครบ 5 ตัวอักษรภายใน ~50ms)

  | ลำดับที่ตอบกลับ | Query | ยิงออก | ตอบกลับ | Latency | Results |
  |---|---|---|---|---|---|
  | 1 | `sushi` | 20:03:56.851 | 20:03:57.072 | 221ms | 5 |
  | 2 | `sush` | 20:03:56.847 | 20:03:57.178 | 331ms | 5 |
  | 3 | `sus` | 20:03:56.841 | 20:03:57.495 | 654ms | 5 |
  | 4 | `su` | 20:03:56.809 | 20:03:57.653 | 844ms | 26 |
  | 5 | `s` | 20:03:56.800 | 20:03:57.965 | 1165ms | **115 ← final UI state** |

- ดังนั้น search "s" จึงมาทีหลังและทำให้ข้อมูลที่ได้หลังสุดเป็นของ search "s" แต่ใน UI ช่องค้นหาเป็น sushi
...

**Fix — why it's the right one**
- แก้โดยการสร้าง _latestRequestId มาเก็บค่าว่าเรามีการ request ล่าสุดลำดับไหน เพื่อที่จะได้แสดงข้อมูล request ตัวล่าสุด ไม่ใช่แสดงข้อมูล request ตัวที่มาช้าสุด
- มันแก้ที่ต้นเหตุเพราะต้นเหตุปัญหามันมาจากโค้ดที่ทำจะแสดงข้อมูลที่มาหลังสุด แต่ปัญหาคือข้อมูลที่มาหลังสุดไม่ใช่ข้อมูลล่าสุดที่เราต้องการ
...

**Alternative considered & rejected**
- การ delay การค้นหาข้อมูลหรือการทำ Debounce มันอาจแก้ปัญหาได้คร่าวๆแต่มันก็ไม่ได้ลบต้นเหตุ
...

**Edge cases**
- การใช้ _latestRequestId ร่วมกับ Debounce เพื่อลดการใช้งาน api ที่ไม่จำเป็น และยังทำให้หน้าจอดูสมูทกว่าการยิง api ทุกครั้ง
- บางทีอาจจะหาลือเรื่องการทำ pagination กับฝั่ง backend ถ้ากรณีข้อมูลเยอะมากอาจทำให้ใช้เวลาในการดึงเยอะและทำให้หนักเกินไปในการค้นหาหนึ่งครั้ง
- ในการโหลดข้อมูลอาจเปลี่ยนจาก circle loading เป็น shimmer เพื่อความสมูท
---

### RES-102 · Crash after leaving My orders

**Root cause**
<!-- สาเหตุที่แท้จริงคืออะไร? ค่าผิดมาจากไหน? (ไม่ใช่แค่บอกว่าแก้บรรทัดไหน) -->
...

**Fix — why it's the right one**
<!-- แก้ยังไง? ทำไมถึงเป็นการแก้ที่ต้นเหตุ ไม่ใช่แค่ปิดอาการ? -->
...

**Alternative considered & rejected**
<!-- มีวิธีอื่นที่คิดไว้แต่ไม่เลือกไหม? ทำไมถึงไม่เลือก? -->
...

**Edge cases**
<!-- คิดถึงเคสไหนบ้าง? มีเคสไหนที่ตั้งใจไม่ทำ เพราะอะไร? -->
- ...

---

### RES-103 · Requests pile up the longer you browse

**Root cause**
<!-- สาเหตุที่แท้จริงคืออะไร? ค่าผิดมาจากไหน? (ไม่ใช่แค่บอกว่าแก้บรรทัดไหน) -->
...

**Fix — why it's the right one**
<!-- แก้ยังไง? ทำไมถึงเป็นการแก้ที่ต้นเหตุ ไม่ใช่แค่ปิดอาการ? -->
...

**Alternative considered & rejected**
<!-- มีวิธีอื่นที่คิดไว้แต่ไม่เลือกไหม? ทำไมถึงไม่เลือก? -->
...

**Edge cases**
<!-- คิดถึงเคสไหนบ้าง? มีเคสไหนที่ตั้งใจไม่ทำ เพราะอะไร? -->
- ...

---

### RES-104 · Duplicate deals in the home feed

**Root cause**
<!-- สาเหตุที่แท้จริงคืออะไร? ค่าผิดมาจากไหน? (ไม่ใช่แค่บอกว่าแก้บรรทัดไหน) -->
...

**Fix — why it's the right one**
<!-- แก้ยังไง? ทำไมถึงเป็นการแก้ที่ต้นเหตุ ไม่ใช่แค่ปิดอาการ? -->
...

**Alternative considered & rejected**
<!-- มีวิธีอื่นที่คิดไว้แต่ไม่เลือกไหม? ทำไมถึงไม่เลือก? -->
...

**Edge cases**
<!-- คิดถึงเคสไหนบ้าง? มีเคสไหนที่ตั้งใจไม่ทำ เพราะอะไร? -->
- ...

---

### RES-105 · Home feed is janky and memory keeps climbing

**Root causes**
<!-- โจทย์บอกว่ามีมากกว่า 1 สาเหตุ แต่ละสาเหตุคืออะไร? -->
1. ...
2. ...

**Fix — why it's the right one**
<!-- แก้แต่ละสาเหตุยังไง? ทำไมถึงเป็นการแก้ที่ต้นเหตุ? -->
...

**Alternative considered & rejected**
<!-- มีวิธีอื่นที่คิดไว้แต่ไม่เลือกไหม? ทำไมถึงไม่เลือก? -->
...

**Edge cases**
<!-- คิดถึงเคสไหนบ้าง? มีเคสไหนที่ตั้งใจไม่ทำ เพราะอะไร? -->
- ...

**DevTools evidence — before / after**
<!-- ข้อนี้บังคับ: ใส่ตัวเลขหรือสกรีนช็อตจาก DevTools เช่น frame time, rebuild count, memory, image cache -->

| Metric | Before | After |
| --- | --- | --- |
| ... | ... | ... |

---

### RES-106 · Wrong pickup times; "Pickup today" filter misses deals

**Root cause**
<!-- สาเหตุที่แท้จริงคืออะไร? ค่าผิดมาจากไหน? (ไม่ใช่แค่บอกว่าแก้บรรทัดไหน) -->
...

**Fix — why it's the right one**
<!-- แก้ยังไง? ทำไมถึงเป็นการแก้ที่ต้นเหตุ ไม่ใช่แค่ปิดอาการ? -->
...

**Alternative considered & rejected**
<!-- มีวิธีอื่นที่คิดไว้แต่ไม่เลือกไหม? ทำไมถึงไม่เลือก? -->
...

**Edge cases**
<!-- คิดถึงเคสไหนบ้าง? มีเคสไหนที่ตั้งใจไม่ทำ เพราะอะไร? -->
- ...

---

### RES-107 · Deep link opens to a crash

**Root cause**
<!-- สาเหตุที่แท้จริงคืออะไร? ค่าผิดมาจากไหน? (ไม่ใช่แค่บอกว่าแก้บรรทัดไหน) -->
...

**Fix — why it's the right one**
<!-- แก้ยังไง? (โจทย์บังคับให้เปิดหน้าดีลที่ใช้งานได้จริง แสดงหน้า error แทนไม่ได้) -->
...

**Alternative considered & rejected**
<!-- มีวิธีอื่นที่คิดไว้แต่ไม่เลือกไหม? ทำไมถึงไม่เลือก? -->
...

**Edge cases**
<!-- คิดถึงเคสไหนบ้าง? มีเคสไหนที่ตั้งใจไม่ทำ เพราะอะไร? -->
- ...

---

## Part B — Features

### F-1 · Live flash-sale countdowns

**Approach**
<!-- ทำยังไง? ทำให้ rebuild ทุกวินาทีเกิดแค่ที่ข้อความนับถอยหลังได้ยังไง? -->
...

**Why this approach**
<!-- ทำไมเลือกวิธีนี้? ทำไมยังลื่นแม้มี countdown 100+ ตัว? -->
...

**Alternative considered & rejected**
<!-- มีวิธีอื่นที่คิดไว้แต่ไม่เลือกไหม? ทำไมถึงไม่เลือก? -->
...

**Edge cases**
<!-- เช่น หมดเวลาตอนการ์ดอยู่นอกจอ / ตอนดีลอยู่ในตะกร้าแล้ว / ตอนเปิดหน้า details อยู่ -->
- ...

**DevTools evidence**
<!-- ตัวเลขหรือสกรีนช็อตที่แสดงว่า rebuild แค่ข้อความ ไม่ใช่ทั้งการ์ดหรือทั้งลิสต์ -->
...

---

### F-2 · Impression tracking

**Approach**
<!-- ตรวจว่ามองเห็น ≥50% นาน ≥1 วินาทียังไง? กันไม่ให้ส่งซ้ำ (1 ครั้งต่อดีลต่อเซสชัน) ยังไง? ส่งเป็น batch เมื่อครบ 10 events หรือ 15 วินาทียังไง? -->
...

**Why this approach**
<!-- ทำไมเลือกวิธีนี้? ทำไม scroll ถึงไม่ช้าลง? -->
...

**Alternative considered & rejected**
<!-- มีวิธีอื่นที่คิดไว้แต่ไม่เลือกไหม? ทำไมถึงไม่เลือก? -->
...

**Edge cases**
<!-- เช่น ดีลเดียวกันโผล่หลายหน้าจอ / เลื่อนผ่านเร็วไม่ถึง 1 วินาที / ส่ง batch ไม่สำเร็จ / แอปถูกพับไปพื้นหลัง -->
- ...

---

### F-3 · Stock reservations with optimistic UI

**Approach**
<!-- จองตอน add to bag ยังไง? จองไม่สำเร็จแล้วถอยกลับยังไง? แสดงเวลาที่เหลือต่อรายการยังไง? ลบหรือลดจำนวนแล้วปล่อยการจองยังไง? จัดการ 410 ตอน checkout ยังไง? -->
...

**Why this approach**
<!-- ทำไมเลือกวิธีนี้? -->
...

**Alternative considered & rejected**
<!-- มีวิธีอื่นที่คิดไว้แต่ไม่เลือกไหม? ทำไมถึงไม่เลือก? -->
...

**Product decision: reservation expires while the user is in the app / mid-checkout**
<!-- ข้อนี้บังคับ: ตัดสินใจเองว่าแอปควรทำอะไร และให้เหตุผลว่าทำไมถึงดีต่อผู้ใช้ -->
...

**Edge cases**
<!-- เช่น หมดอายุระหว่างรอ checkout ตอบกลับ / กดเพิ่มหรือลบรัวๆ / ได้ 409 เพราะสต็อกถูกแย่ง -->
- ...

---

## AI usage log

**Tools used & what for**
<!-- ใช้ AI ตัวไหน? ใช้ทำอะไรบ้าง? -->
- ใช้สอนและอธิบายโค้ดที่ไม่เข้าใจ
- ให้ช่วยนำเสนอแนวทางในการแก้ปัญหา
- ใช้เขียนโค้ดที่ต้องการให้

**Example 1 — AI was wrong / misleading**
<!-- AI แนะนำอะไร? รู้ได้ยังไงว่าผิด? แล้วทำอะไรแทน? -->
- Suggested: ...
- How I caught it: ...
- What I did instead: ...

**Example 2 — AI was wrong / misleading**
<!-- AI แนะนำอะไร? รู้ได้ยังไงว่าผิด? แล้วทำอะไรแทน? -->
- Suggested: ...
- How I caught it: ...
- What I did instead: ...

---

## Design questions

**Q1. In this codebase, what is the difference between a `GetxController`'s lifecycle and a widget `State`'s lifecycle? Name one bug from Part A that exists because of confusion between the two.**
<!-- ตอบประมาณ 1 ย่อหน้า และต้องยกบั๊กจาก Part A มา 1 ข้อ -->
...

**Q2. When does wrapping a large subtree in a single `Obx` hurt you? How do you decide how tightly to scope reactivity?**
<!-- ตอบประมาณ 1 ย่อหน้า -->
...

**Q3. How would you write an automated test that would have caught RES-106 before release? What (if anything) would you change in the code to make such a test possible?**
<!-- ตอบประมาณ 1 ย่อหน้า -->
...

---

## Time spent

<!-- ใส่เวลาตามจริงโดยประมาณ -->

| Item | Time |
| --- | --- |
| RES-101 | 2-3 ชม. |
| RES-102 | ... |
| RES-103 | ... |
| RES-104 | ... |
| RES-105 | ... |
| RES-106 | ... |
| RES-107 | ... |
| F-1 | ... |
| F-2 | ... |
| F-3 | ... |
| solutions.md | ... |
| **Total** | ... |

**With one more day, I would:**
<!-- ถ้ามีเวลาเพิ่มอีก 1 วัน จะทำอะไรต่อ? เพราะอะไร? -->
...
