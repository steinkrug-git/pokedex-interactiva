# Mi Pokédex Interactiva

Aplicación desarrollada en Flutter que consume la PokeAPI para mostrar un listado interactivo de Pokémon. El proyecto incluye funcionalidades avanzadas como paginación (infinite scroll), búsqueda en tiempo real y transiciones animadas.

## Integrantes
- Alejandro Ezequiel Martínez Paredes (alexandre-martinoli)
- Aldo González Colmán (steinkrug)
- Carlos Daniel Zarate Martinez (CarlZarat)
- Catalina Monzón Almada (catalina1998)

## Funcionalidades Implementadas

### 1. Pantalla Principal (Listado)
- **Infinite Scroll (Paginación):** Implementación de carga perezosa (Lazy Loading) que carga los Pokémon de 20 en 20 para optimizar el rendimiento y evitar bloqueos de API.
- **Indicadores de Carga:** Visualización de `CircularProgressIndicator` al llegar al final de la lista mientras se obtienen más datos.
- **Diseño:** Uso de `Card` y `ListTile` con imágenes y tipografía clara.

### 2. Búsqueda
- **SearchDelegate Nativo:** Implementación de una barra de búsqueda en el `AppBar` que permite encontrar Pokémon por nombre específico.
- **Manejo de Errores:** Mensaje visual "No se encontraron resultados" si la búsqueda no coincide con ningún Pokémon.

### 3. Pantalla de Detalle
- **Navegación:** Al tocar un Pokémon, se abre una ficha detallada.
- **Datos Extra:** Consumo del endpoint individual (`/pokemon/{id}`) para mostrar:
  - Tipos (Chips de colores).
  - Altura y Peso.
  - Sprite en alta calidad.

### 4. Bonus (Extras)
- **Animaciones Hero:** Transición fluida de la imagen del Pokémon desde la lista hacia la pantalla de detalle ("vuelo" de la imagen).
- **Optimización Web:** Configuración específica para evitar errores de renderizado en navegadores.

---

## Desafíos Encontrados y Soluciones

Durante el desarrollo nos enfrentamos a varios retos técnicos, especialmente relacionados con la versión Web de Flutter:

1.  **Error 429 (Too Many Requests):**
    - *Problema:* Al intentar cargar los 1500 Pokémon iniciales, la API bloqueaba la conexión por exceso de peticiones.
    - *Solución:* Implementamos lógica de paginación (`limit=20` & `offset=x`) para realizar peticiones pequeñas y controladas.

2.  **Imágenes rotas en Web (CORS):**
    - *Problema:* El navegador bloqueaba las imágenes de fuentes externas por políticas de seguridad (CORS) y el renderizador CanvasKit.
    - *Solución:* Configuramos el archivo `index.html` para inyectar `window.flutterConfiguration = { renderer: "html" }`, forzando el uso del renderizador HTML que es más permisivo con imágenes externas.

3.  **Bloqueo de IP temporal:**
    - *Problema:* GitHub bloqueó temporalmente nuestra IP por pruebas intensivas.
    - *Solución:* Alternamos servidores de imágenes (unpkg vs raw.githubusercontent) y optimizamos el código para reducir llamadas innecesarias.

---

## Aprendizajes del Proyecto

- **Consumo de APIs REST:** Aprendimos a manejar peticiones `http` asíncronas, decodificar JSON y manejar estados de carga/error.
- **Gestión del Scroll:** Comprendimos cómo usar `ScrollController` para detectar el final de una lista y disparar eventos.
- **Flutter Web:** Aprendimos las diferencias críticas entre correr una app en móvil vs web (renderizadores y CORS).
- **Widgets de Animación:** Uso práctico del widget `Hero` para mejorar la experiencia de usuario (UX).

---

## Cómo ejecutar el proyecto

1. Clonar el repositorio.
2. Obtener las dependencias:
   ```bash
   flutter pub get
