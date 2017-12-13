import ReactOnRails from 'react-on-rails';

import DateTimeInput from '../bundles/DateTimeInput/components/DateTimeInput';

import StyleControl from '../bundles/StyleControl/components/StyleControl';
import FontColorButton from '../bundles/StyleControl/components/FontColorButton';
import FontExample from '../bundles/StyleControl/components/FontExample';
import FontMenu from '../bundles/StyleControl/components/FontMenu';
import FontSize from '../bundles/StyleControl/components/FontSize';
import FontStyle from '../bundles/StyleControl/components/FontStyle';

import TemplateEditor from '../bundles/TemplateEditor/components/TemplateEditor';

import ThumbnailControl from '../bundles/ThumbnailControl/components/ThumbnailControl';


ReactOnRails.register({
  DateTimeInput,
  StyleControl, FontColorButton, FontExample, FontMenu, FontSize, FontStyle,
  TemplateEditor,
  ThumbnailControl,
});
