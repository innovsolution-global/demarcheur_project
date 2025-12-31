import 'package:demarcheur_app/models/house_model.dart';
import 'package:flutter/material.dart';

class HouseProvider extends ChangeNotifier {
  List<HouseModel> _allhouses = [];
  List<HouseModel> _housefiltered = [];
  bool _viewAll = false;
  bool get viewAll => _viewAll;
  bool _isLoading = false;
  List<HouseModel> get allhouses => _allhouses;
  static const int _limit = 2;
  List<HouseModel> get firstFiveHouses => _housefiltered.length > _limit
      ? _housefiltered.take(_limit).toList()
      : _housefiltered;
  List<HouseModel> get housefiltered => _housefiltered;

  bool get isLoading => _isLoading;
  void setHouseFiltered(List<HouseModel> houses) {
    _housefiltered = houses;
    notifyListeners();
  }

  void toggleView() {
    _viewAll = !_viewAll;
    notifyListeners();
  }

  void searchHouse(String query) {
    if (query.isEmpty) {
      _housefiltered = _allhouses;
    } else {
      final q = query.toLowerCase();
      _housefiltered = _allhouses
          .where(
            (job) =>
                job.companyName.toLowerCase().contains(q) ||
                job.location.toLowerCase().contains(q) ||
                job.category.toLowerCase().contains(q),
          )
          .toList();
    }

    _viewAll = false; // reset view when new search
    notifyListeners();
  }

  Future<void> loadHous() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(Duration(milliseconds: 1500));
    _allhouses = [
      HouseModel(
        id: "1",
        companyName: "Guimo",
        countType: "Agence immobiliere",
        logo:
            "https://tse3.mm.bing.net/th/id/OIP.BtAeSLjoF_i6lP_LfRzymQHaE8?rs=1&pid=ImgDetMain&o=7&rm=3",
        imageUrl: [
          "https://tse4.mm.bing.net/th/id/OIP.pLwgByIjX5RbJfAEtniTcwHaEo?rs=1&pid=ImgDetMain&o=7&rm=3",
        ],
        postDate: "il y 45 minutes",
        rent: 15000000,
        location: "Coyah",
        type: "Indutrie",
        rate: 3.5,
        status: "Disponible",
        category: "Baille",
      ),
      HouseModel(
        id: "1",
        countType: "Agence immobiliere",
        companyName: "Guimo",
        logo:
            "https://tse3.mm.bing.net/th/id/OIP.BtAeSLjoF_i6lP_LfRzymQHaE8?rs=1&pid=ImgDetMain&o=7&rm=3",
        imageUrl: [
          "https://tse4.mm.bing.net/th/id/OIP.DkVSJXthCEz5BIkkf07o8wHaEB?w=1800&h=976&rs=1&pid=ImgDetMain&o=7&rm=3",
        ],
        postDate: "il y 45 minutes",
        rent: 920000,
        location: "Cosa",
        type: "Appartement",
        rate: 5.2,
        status: "Disponible",
        category: "Terrain",
      ),
      HouseModel(
        id: "1",
        companyName: "Guimo",
        countType: "Agence immobiliere",

        logo:
            "https://tse3.mm.bing.net/th/id/OIP.BtAeSLjoF_i6lP_LfRzymQHaE8?rs=1&pid=ImgDetMain&o=7&rm=3",
        imageUrl: [
          "https://th.bing.com/th/id/R.0ffcaf8bf7ded71bcb7a5ee57c03ecdf?rik=EQDHUg6m0a4XKA&pid=ImgRaw&r=0",
        ],
        postDate: "il y 45 minutes",
        rent: 650000.0,
        location: "Sonfonia",
        type: "A vendre",
        rate: 5.2,
        status: "Disponible",
        category: "A louer",
      ),
      HouseModel(
        id: "1",
        companyName: "Guimo Immobilie",
        countType: "Agence immobiliere",

        logo:
            "https://tse3.mm.bing.net/th/id/OIP.BtAeSLjoF_i6lP_LfRzymQHaE8?rs=1&pid=ImgDetMain&o=7&rm=3",
        imageUrl: [
          "https://tse4.mm.bing.net/th/id/OIF.4YKR5MyHcJYp9M5ar4amWg?rs=1&pid=ImgDetMain&o=7&rm=3",
        ],
        postDate: "il y 45 minutes",
        rent: 15.0,
        location: "T7",
        type: "Appartement",
        rate: 5.2,
        status: "Disponible",
        category: "Terrain",
      ),
      HouseModel(
        id: "1",
        companyName: "Guimo",
        countType: "Agence immobiliere",

        logo:
            "https://tse3.mm.bing.net/th/id/OIP.BtAeSLjoF_i6lP_LfRzymQHaE8?rs=1&pid=ImgDetMain&o=7&rm=3",
        imageUrl: [
          "https://th.bing.com/th/id/R.7db2eeeb0f03eadc9be27a2cbe0b278a?rik=hXWIy3SWgUAnJQ&pid=ImgRaw&r=0",
        ],
        postDate: "il y 45 minutes",
        rent: 450000,
        location: "Lansanah",
        type: "Appartement",
        rate: 2.2,
        status: "Disponible",
        category: "Terrain",
      ),
      HouseModel(
        id: "1",
        companyName: "Guimo",
        countType: "Agence immobiliere",

        logo:
            "https://tse3.mm.bing.net/th/id/OIP.BtAeSLjoF_i6lP_LfRzymQHaE8?rs=1&pid=ImgDetMain&o=7&rm=3",
        imageUrl: [
          "https://media.salecore.com/salesaspects/shared/GlobalImageLibrary/Responsive/ElegantSeller/real-estate-home-interior-28-1760-1000.jpg",
        ],
        postDate: "il y 45 minutes",
        rent: 500000.0,
        location: "Kobayah",
        type: "Appartement",
        rate: 5.2,
        status: "Disponible",
        category: "Terrain",
      ),
      HouseModel(
        id: "1",
        companyName: "Guimo",
        countType: "Agence immobiliere",

        logo:
            "https://tse3.mm.bing.net/th/id/OIP.BtAeSLjoF_i6lP_LfRzymQHaE8?rs=1&pid=ImgDetMain&o=7&rm=3",
        imageUrl: [
          "https://blog.hdestates.com/wp-content/uploads/2020/05/Photograph-Real-Estate-Interiors.jpg",
        ],
        postDate: "il y 45 minutes",
        rent: 2000000.0,
        location: "Cimenterie",
        type: "Hotel",
        rate: 5.2,
        status: "Disponible",
        category: "A vendre",
      ),
      HouseModel(
        id: "1",
        companyName: "Guimo",
        countType: "Agence immobiliere",

        logo:
            "https://tse3.mm.bing.net/th/id/OIP.BtAeSLjoF_i6lP_LfRzymQHaE8?rs=1&pid=ImgDetMain&o=7&rm=3",
        imageUrl: [
          "https://tse2.mm.bing.net/th/id/OIP.c-GQHGXEet5pJ0ECKkaXFQHaE5?rs=1&pid=ImgDetMain&o=7&rm=3",
        ],
        postDate: "il y a 1 heure",
        rent: 8000000,
        location: "Coyah",
        type: "Industrie",
        rate: 5.2,
        status: "Plus disponible",
        category: "Terrain",
      ),
      HouseModel(
        id: "1",
        companyName: "Guimo",
        countType: "Agence immobiliere",

        logo:
            "https://img.freepik.com/premium-photo/real-estate-business-idea_874813-37777.jpg",
        imageUrl: [
          "https://tse2.mm.bing.net/th/id/OIP.rFxW0CBwvuiEP9_355va0AHaFE?w=2000&h=1371&rs=1&pid=ImgDetMain&o=7&rm=3",
        ],
        postDate: "il y a 10 minutes",
        rent: 1000000.0,
        location: "Kaloum",
        type: "Hotel",
        category: "A Louer",

        rate: 4.2,
        status: "Plus disponible",
      ),
      HouseModel(
        id: "1",
        companyName: "Luxyrus",
        countType: "Agence immobiliere",

        logo:
            "https://tse4.mm.bing.net/th/id/OIP.OTraLZIT9N98YwJ1N6rVsAHaEK?rs=1&pid=ImgDetMain&o=7&rm=3",
        imageUrl: [
          "https://vantolins.com/wp-content/uploads/2015/07/shutterstock_270084692.jpg",
          "https://terrarealestate.com/img/3376/terra-68ebbe080d155.jpg",
        ],
        postDate: "il y a 1 minutes",
        rent: 1500000,
        location: "Sonfonia",
        type: "Appartement",
        category: "A vendre",
        rate: 5.2,
        status: "Disponible",
      ),
    ];
    _housefiltered = _allhouses;
    _isLoading = false;
    notifyListeners();
  }

  // 🔹 Dynamic categories list (always up-to-date)
  List<String> get categories {
    final uniqueCategories = _allhouses
        .map((house) => house.category)
        .toSet()
        .toList();
    uniqueCategories.sort(); // optional: sort alphabetically
    return ['Tout', ...uniqueCategories];
  }

  void clearSearch() {
    _housefiltered = _allhouses;
    _viewAll = false;
    notifyListeners();
  }
}
