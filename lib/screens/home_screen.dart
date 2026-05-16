import 'package:flutter/material.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final List<Map<String, dynamic>> books = const [
  {
    "image":
        "https://covers.openlibrary.org/b/isbn/9780140328721-L.jpg",
    "price": 350,
  },
  {
    "image":
        "https://covers.openlibrary.org/b/isbn/9780439064873-L.jpg",
    "price": 420,
  },
  {
    "image":
        "https://covers.openlibrary.org/b/isbn/9780261103573-L.jpg",
    "price": 280,
  },
  {
    "image":
        "https://covers.openlibrary.org/b/isbn/9780307277671-L.jpg",
    "price": 500,
  },
  {
    "image":
        "https://covers.openlibrary.org/b/isbn/9780743273565-L.jpg",
    "price": 390,
  },
  {
    "image":
        "https://covers.openlibrary.org/b/isbn/9780061120084-L.jpg",
    "price": 610,
  },
];

  @override
  Widget build(BuildContext context) {
    final List<String> tabs = [
      "Explore",
      "Explore",
      "Explore",
      "Explore",
      "Explore",
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF2100B8),
      body: SafeArea(
        child: Column(
          children: [
            // TOP SECTION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Educart",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // SEARCH BAR
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6E8CFF),
                      borderRadius: BorderRadius.circular(35),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 18),
                        const Icon(Icons.search, color: Colors.white, size: 34),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const TextField(
                              decoration: InputDecoration(
                                hintText: "Search books...",
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 18),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // TABS
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: tabs.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 28),
                          child: Column(
                            children: [
                              Text(
                                tabs[index],
                                style: TextStyle(
                                  color: index == 0
                                      ? Colors.white
                                      : Colors.white70,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 6),
                              if (index == 0)
                                Container(
                                  width: 70,
                                  height: 2,
                                  color: Colors.white,
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // 📚 GRID
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: books.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.68,
                ),
                itemBuilder: (context, index) {
                  final book = books[index];

                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF5F7CFF),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      children: [
                        // 📖 BOOK COVER
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              image: DecorationImage(
                                image: NetworkImage(book["image"]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),

                        // 💰 PRICE SECTION
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            "৳ ${book["price"]}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // ❤️ + 🛒 BUTTONS (FIXED NO OVERFLOW)
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 12, right: 12, bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                height: 40,
                                width: 45,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFA8C8FF),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Icon(
                                  Icons.favorite_border,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: const Icon(
                                    Icons.add_shopping_cart_outlined,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // BOTTOM NAV (UNCHANGED)
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        height: 85,
        decoration: BoxDecoration(
          color: const Color(0xFF8EB6FF),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            navItem(Icons.home_outlined),
            navItem(Icons.notifications_none),
            navItem(Icons.shopping_cart_outlined),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfileScreen(),
                  ),
                );
              },
              child: navItem(Icons.person_outline),
            ),
          ],
        ),
      ),
    );
  }

  Widget navItem(IconData icon) {
    return Container(
      height: 55,
      width: 55,
      decoration: const BoxDecoration(
        color: Color(0xFF3E7DDB),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 30),
    );
  }
}
