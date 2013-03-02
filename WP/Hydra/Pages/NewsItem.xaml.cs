using System;
using System.Linq;
using System.Text;
using System.Windows;
using System.Windows.Media;
using System.Windows.Navigation;
using Microsoft.Phone.Controls;

namespace Hydra.Pages
{
    public partial class NewsItem : PhoneApplicationPage
    {
        public NewsItem()
        {
            InitializeComponent();
        }

        // Load data for the ViewModel NewsItems
        protected override void OnNavigatedTo(NavigationEventArgs e)
        {

            try
            {
                var item = App.ViewModel.NewsItems.ElementAt(Convert.ToInt32(NavigationContext.QueryString["newsItem"]));
                DataContext = item;
                var fullhtml = WrapHtml(item.Content, browser.ActualWidth);
                browser.NavigateToString(fullhtml);
            }
            catch (Exception ex)
            {
                NavigationService.Navigate(new Uri("/Pages/MainPage.xaml", UriKind.Relative));
            }

        }

        private void HandleLinks(object sender, NotifyEventArgs e)
        {

            browser.Dispatcher.BeginInvoke(
                 () => InfoItemBrowser.BrowseToUrl(e.Value)
                 );

        }


        public static string WrapHtml(string htmlSubString, double viewportWidth)
        {
            var html = new StringBuilder();
            html.Append("<html>");
            html.Append(HtmlHeader(viewportWidth));
            html.Append("<body>");
            html.Append(htmlSubString);
            html.Append("</body>");
            html.Append("</html>");
            return html.ToString();
        }

        public static string NotifyScript
        {
            get
            {
                return @"<script>
                    window.onload = function(){
                        a = document.getElementsByTagName('a');
                        for(var i=0; i < a.length; i++){
                            var msg = a[i].href;
                            a[i].onclick = function() {notify(msg);};
                        }
                    }
                    function notify(msg) {
	                window.external.Notify(msg); 
	                event.returnValue=false;
	                return false;
                    }
                    </script>";
            }
        }

        private static string GetBrowserColor(string sourceResource)
        {
            var color = (Color)Application.Current.Resources[sourceResource];
            return "#" + color.ToString().Substring(3, 6);
        }
        public static string HtmlHeader(double viewportWidth)
        {
            var head = new StringBuilder();

            head.Append("<head>");
            head.Append(string.Format(
            "<meta name=\"viewport\" value=\"width={0}\" user-scalable=\"no\">",
            viewportWidth));
            head.Append("<style>");
            head.Append("html { -ms-text-size-adjust:150% }");
            head.Append(string.Format(
            "body {{background:{0};color:{1};font-family:'Segoe WP';font-size:{2}pt;margin:0;padding:0 }}",
            GetBrowserColor("PhoneBackgroundColor"),
            GetBrowserColor("PhoneForegroundColor"),
            (double)Application.Current.Resources["PhoneFontSizeNormal"]));
            head.Append(string.Format(
            "a {{color:{0}}}",
            GetBrowserColor("PhoneAccentColor")));
            head.Append("</style>");
            head.Append(NotifyScript);
            head.Append("</head>");

            return head.ToString();
        }
    }
}