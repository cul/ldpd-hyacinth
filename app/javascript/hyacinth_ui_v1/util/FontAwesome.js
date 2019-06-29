// Font Awesome usage with react: https://fontawesome.com/how-to-use/on-the-web/using-with/react

// Import library so we can add specific icons used in our app
import { library } from '@fortawesome/fontawesome-svg-core';

// Import and add icons to library
import {
  faBell,
  faPlus,
  faPen,
  faTimes,
  faCaretUp,
  faCaretDown,
  faAngleDoubleDown,
  faAngleDoubleUp,
  faInfoCircle,
  faExternalLinkSquareAlt,
} from '@fortawesome/free-solid-svg-icons';

import {
  faCaretSquareUp,
  faCaretSquareDown,
} from '@fortawesome/free-regular-svg-icons';

library.add(
  faBell,
  faPlus,
  faPen,
  faTimes,
  faCaretUp,
  faCaretDown,
  faCaretSquareUp,
  faCaretSquareDown,
  faAngleDoubleDown,
  faAngleDoubleUp,
  faInfoCircle,
  faExternalLinkSquareAlt,
);
