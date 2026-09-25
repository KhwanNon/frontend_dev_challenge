# Solutions

## Part A — Bug tickets

### RES-101 · Search shows results for the wrong query

**Root cause**
- The longer the query, the faster the response comes back, so responses arrive out of order.

  Repro: `adb shell input text sushi` on the Search screen (all 5 characters are sent within ~50ms)

  | Response order | Query | Sent | Received | Latency | Results |
  |---|---|---|---|---|---|
  | 1 | `sushi` | 20:03:56.851 | 20:03:57.072 | 221ms | 5 |
  | 2 | `sush` | 20:03:56.847 | 20:03:57.178 | 331ms | 5 |
  | 3 | `sus` | 20:03:56.841 | 20:03:57.495 | 654ms | 5 |
  | 4 | `su` | 20:03:56.809 | 20:03:57.653 | 844ms | 26 |
  | 5 | `s` | 20:03:56.800 | 20:03:57.965 | 1165ms | **115 ← final UI state** |

- So the response for "s" arrives last, and the final results shown are for "s" while the search field says "sushi".

**Fix — why it's the right one**
- Added `_latestRequestId` to track which request is the most recent, so the screen shows the results of the latest request rather than the request that happened to arrive last.
- This fixes the root cause: the code displayed whichever response arrived last, but the last response to arrive is not necessarily the latest one we asked for.

**Alternative considered & rejected**
- Delaying the search or adding a debounce might roughly hide the problem, but it doesn't remove the root cause.

**Edge cases**
- Combine `_latestRequestId` with a debounce to cut unnecessary API calls; the screen also feels smoother than firing a request on every keystroke.
- Consider discussing pagination with the backend — with very large datasets, a single search could take too long and be too heavy.
- Replace the circular loading indicator with a shimmer for a smoother loading experience.

---

### RES-102 · Crash after leaving My orders

**Root cause**
- `Timer.periodic` keeps calling `setState` after the page has already been disposed.

**Fix — why it's the right one**
- Stored the timer in `_ticker` so it can be cancelled when we leave the page (`dispose()`).

**Edge cases**
- Replace the circular loading indicator with a shimmer for a smoother loading experience.
- Split the screen into tabs by order status, so each API call is lighter and the screen is less complex.
- Consider adding search to this screen.
- For order history, discuss pagination with the backend.

---

### RES-103 · Requests pile up the longer you browse

**Root cause**
- Every time a deal page opens, `onInit` stores the deal and subscribes a listener with `ever` to watch `itemCount`; when it changes, `_recheckAvailability` is called.
- When the page is closed, the controller and screen are disposed, but the listener registered on `CartService` is never removed. So a single "add" triggers every listener ever registered, for every deal visited.

**Fix — why it's the right one**
- Stored the subscription in a `Worker` (`_cartWorker`) and dispose it on close, which removes the listener from `CartService`.

---

### RES-107 · Deep link opens to a crash

**Root cause**
- The deal details page expects the full `DealModel` to be passed in when it opens, but a deep link passes nothing in `Get.arguments`, so it throws `type 'Null' is not a subtype of type 'DealModel'`.

**Fix — why it's the right one**
- Reworked the flow to support deep links: first check whether the argument is a `DealModel`. If it is, set it and display it; if not, fetch the deal from the API, with an error-handling path for malformed input.

**Edge cases**
- Consider discussing with the backend a split in data fetching: the deal list endpoint returns only what the list needs, and the details page fetches a separate by-ID details endpoint. This is a quick idea for the case where a real system has a lot of data on the details page — the page would then only need to accept an ID and call the API. The more cases the frontend has to handle, the more chances for errors.

---

## AI usage log

**Tools used & what for**
- Claude Code
- To teach and explain code I didn't understand
- To propose approaches for solving problems
- To write code I asked for
- To help find problems

---

## Design questions

**Q1. In this codebase, what is the difference between a `GetxController`'s lifecycle and a widget `State`'s lifecycle? Name one bug from Part A that exists because of confusion between the two.**
- A `GetxController`'s lifecycle is tied to the route, while a `State`'s lifecycle is tied to the widget. A widget's `State` can be created and destroyed many times while the controller stays alive, because the controller belongs to the route.
- Example bug: RES-103. `DealDetailsController.onInit` calls `ever(cartService.itemCount, ...)` but never keeps the `Worker` or disposes it in `onClose`, so listener subscriptions keep stacking up.

**Q2. When does wrapping a large subtree in a single `Obx` hurt you? How do you decide how tightly to scope reactivity?**
- `Obx` rebuilds everything it wraps, so the larger the subtree, the more device resources it uses, and it can cause visible jank.
- Wrap `Obx` only around the widgets that actually need to change — for example, just a `Text()`.

**Q3. How would you write an automated test that would have caught RES-106 before release? What (if anything) would you change in the code to make such a test possible?**
- As I understand it, the original code displays time in UTC; it should convert to Thailand time first.
- I would change `isToday` to take the date/time as a parameter instead of calling `DateTime.now()` itself, so tests can control the time. Otherwise the test would depend on `DateTime.now()`.

---

## Time spent

| Item | Time |
| --- | --- |
| Understanding the brief and planning | 2 hrs |
| Getting a rough understanding of the project and its tooling | 2 hrs |
| RES-101 | 1 hr |
| RES-102 | 15 min |
| RES-103 | 50 min |
| RES-107 | 30 min |
| **Total** | 6-7 hrs |

**With one more day, I would:**
- Start with the file structure: separate color, spacing, text, theme, radius, etc., to support theme switching, make changes easier, and keep the code organized.
- Refactor the code and structure so future work can move faster and more systematically.
