# Projekt 11: Sterownik modułu samozniszczenia droida-łowcy

# Opis
Droidy typu IG-11 produkcji Holowan Laboratories, wykorzystywane zwykle jako łowcy nagród,
wyposażone były w moduł samozniszczenia mający zapobiec pojmaniu droida.<br  />
Zaprogramowana
przez producenta sekwencja autodestrukcji aktywowała się w przypadku znacznej przewagi
nieprzyjaciela, odniesienia krytycznych obrażeń lub unieruchomienia jednostki.<br  />
Polegała na 10-
sekundowym odliczaniu zakończonym detonacją ładunku wybuchowego.
 Odliczanie mogło być
wstrzymane na czas ustania czynników zagrażających droidowi lub anulowane po zakończeniu
walki1
.
# Cel
Celem projektu jest stworzenie układu, który na podstawie informacji z wejść określających
stan droida będzie sterował procedurą samozniszczenia poprzez kontrolę odliczania i detonację
ładunku.

# Zadania
1. **Wymaganie 1 (ocena 3.0):** [ ] <br  />
    - Wejście binarne sygnalizuje znalezienie się robota w stanie zagrożenia wymagające rozpoczęcie 10-sekundowego odliczania na diodach LED w kodzie binarnym.
2. **Wymaganie 2 (ocena 3.5):** [ ] <br  />
     - Wejście binarne sygnalizuje znajdowanie się robota w trybie walki. 
    - Detekcja przewagi
wroga w tym stanie jest sygnalizowana stanem wysokim na drugim wejściu i powoduje rozpoczęcie 10-sekundowej procedury odliczania.
    - Destrukcję sygnalizuje zaświecenie
wszystkich diod. 
    - Stan niski na którymkolwiek z powyższych wejść wstrzymuje odliczanie.
    - Wyjście z trybu walki powoduje wyzerowanie odliczania.
3. **Wymaganie 3 (ocena 4.0):** [ ] <br  />
     - Dodatkowe wejścia binarne sygnalizujące uszkodzenie oraz unieruchomienie.
     - Odliczanie
aktywowane jest przy obecności 2 z 3 zagrażających czynników.
4. **Wymaganie 4 (ocena 4.5):** [ ] <br  />
     - Zmienia się sposób sygnalizowania odliczania: wszystkie diody migają z częstotliwością
3 Hz, a w każdej sekundzie jedna z nich gaśnie na stałe. 
     - Odliczanie 8-sekundowe.
5. **Wymaganie 5 (ocena 5.0):** [ ] <br  />
    - Poziom uszkodzeń określany jest z użyciem pokrętła enkodera.
    - Uszkodzenia powyżej 50%
kwalifikują się do rozpoczęcia odliczania.
6. **Wymaganie 6 (ocena 5.5):** [ ] <br  />
    - Odliczanie widoczne na wyświetlaczu LCD
