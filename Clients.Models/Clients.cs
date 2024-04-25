using System.Xml;

namespace Clients.Models
{
    public class Clients
    {
        public int ID { get; set; }      
        public string Name { get; set; }
        public DateTime BirthDate { get; set; }
        public string AdressData { get; set; }
    }
    public class ClientsImport
    {
        public string xml { get; set; }
    }

}
