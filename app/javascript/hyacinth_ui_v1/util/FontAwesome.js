// Font Awesome usage with react: https://fontawesome.com/how-to-use/on-the-web/using-with/react

// Import library so we can add specific icons used in our app
import { library } from '@fortawesome/fontawesome-svg-core'

// Import and add icons to library
import {
  faBell,
  faEdit
} from '@fortawesome/free-solid-svg-icons';
library.add(
  faBell,
  faEdit
);
