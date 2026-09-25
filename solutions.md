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
- ตัว Timer.periodic ทำการเรียก setState ทั้งๆที่หน้านั้นถูก dispose ไปแล้ว 
...

**Fix — why it's the right one**
- แก้โดยการสร้าง _ticker มาเก็บตัวนับเวลา เพื่อให้เวลาเราออกจากหน้านั้นแล้ว(dispose()) เราจะได้ปิดการทำงานของมันได้
...

**Edge cases**
- ในการโหลดข้อมูลอาจเปลี่ยนจาก circle loading เป็น shimmer เพื่อความสมูท
- อาจะแบ่งจอเป็น tab ให้แยกตามสถานะ เวลาดึง api จะได้ไม่หนักมาก และลดความซับซ้อนของหน้าจอลงด้วย
- อาจจะเพิ่มการค้นหามาในส่วนนี้
- ส่วนประวัติการซื้ออาจคุยกับทาง backend เรื่องการทำ pagination

---

### RES-103 · Requests pile up the longer you browse

**Root cause**
- ทุกครั้งที่เข้าหน้า deal ใน onInit จะรับค่าดีลมาเก็บไว้ และสมัคร listener ด้วย ever เพื่อรอดูว่า itemCount เปลี่ยนไหม ถ้าเปลี่ยนก็จะเรียก _recheckAvailability
- พอออกจากหน้า controller กับหน้าจอถูกปิดไปแล้ว แต่ listener ที่สมัครไว้กับ CartService ไม่ได้ถูกถอดออก พอกด add ครั้งเดียว ทุกตัวที่เคยเก็บไว้ทำงานพร้อมกันทุกดีล
...

**Fix — why it's the right one**
- ต้องสร้าง Worker _cartWorker เพื่อเก็บค่าการสมัคร listener และทำการ dispose มันออกเพื่อเป็นการถอด listener ที่สมัครไว้ออกจาก cartService

---

### RES-107 · Deep link opens to a crash

**Root cause**
- หน้ารายละเอียดดีลทำรองรับไว้ว่า ให้ส่งข้อมูล DealModel ทั้งก้อนตอนเปิดหน้า แต่การเข้าจาก deep link มันไม่ได้ส่งอะไรมาใน Get.arguments เลยมันเลยแจ้งว่า `type 'Null' is not a subtype of type 'DealModel'`
...

**Fix — why it's the right one**
- แก้โฟลใหม่ให้รองรับการทำงานแบบ deep link โดยการเช็คก่อนว่าข้อมูลที่เข้ามาเป็น DealModel ไหมถ้าใช่ก็เซตค่าและแสดง ถ้าไม่ใช่ก็เข้าโฟลดึง api และโฟล handle error ในกรณีที่ข้อมูลผิดรูปแบบ
...

**Edge cases**
- บางทีอาจหารือกับฝั่งหลังบ้านว่าเราควรออกแบบการดึงข้อมูลให้เป็นแบบ เส้นแรกเส้นรายการดีลดึงแค่ข้อมูลที่ต้องแสดง และเข้าหน้ารายละเอียดค่อยดึงอีกเส้นคือเส้นรายละเอียดแยกตามไอดี อันนี่ที่คิดขึ้นมาเร็วๆ เผื่่อกรณีในระบบจริงข้อมูลที่ต้องแสดงหน้ารายละเอียดมันเยอะ และการรับมือเคสจะได้เหลือแค่รับไอดีและยิง api เพราะยิ่งหน้าบ้านรับมือหลายอย่าง โอกาสเกิด error ก็ยิ่งเยอะขึ้น

---

## AI usage log

**Tools used & what for**
- ใช้ claude code
- ใช้สอนและอธิบายโค้ดที่ไม่เข้าใจ
- ให้ช่วยนำเสนอแนวทางในการแก้ปัญหา
- ใช้เขียนโค้ดที่ต้องการให้
- ให้หาปัญหา

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

| Item | Time |
| --- | --- |
| RES-101 | 2-3 ชม. |
| RES-102 | 15 นาที |
| RES-103 | 50 นาที |
| RES-107 | 30 นาที |
| **Total** | 4-5 ชม. |

**With one more day, I would:**
- เรื่องการจัดโครงสร้างของไฟล์ก่อน ควรแยก color, spacing, text, theme, radius บราๆ เพื่อให้รองรับการเปลี่ยนธีมและทำให้แก้ไขได้ง่าย และโค้ดเป็นระเบียบ 
- refactor code และโครงสร้างให้สามารถทำงานต่อได้เร็วและเป็นระบบขึ้น
...
