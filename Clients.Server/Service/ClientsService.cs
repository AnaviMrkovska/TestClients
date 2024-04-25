using Clients.Server.Service.IService;
using System.Net.Http;
using Clients.Models;
using Newtonsoft.Json;
using System.Text;

namespace Clients.Server.Service
{
    public class ClientsService : IClientsService
    {
        private readonly HttpClient _httpClient;
        public ClientsService(HttpClient httpClient)
        {
            _httpClient = httpClient;
        }
        
        public async Task<IEnumerable<Clients.Models.Clients>> GetAllClients()
        {

            var odg = await _httpClient.GetAsync($"api/Clients/GetAllClients");
            if (odg.IsSuccessStatusCode)
            {
                var sodrzhina = await odg.Content.ReadAsStringAsync();
                var res = JsonConvert.DeserializeObject<IEnumerable<Clients.Models.Clients>>(sodrzhina);
                return res;
            }
            else
            {
                var sodrzhina = await odg.Content.ReadAsStringAsync();
                var res = JsonConvert.DeserializeObject<ErrorModel>(sodrzhina);
                throw new Exception("Грешка");
            }
        }

        public async Task<ClientsImport> InsertClientsFromXml(ClientsImport xml)
        {
            var sc = JsonConvert.SerializeObject(xml);
            var bodyContent = new StringContent(sc, Encoding.UTF8, "application/json");
            var odg = await _httpClient.PostAsync($"api/Clients/InsertClientsFromXml", bodyContent);
            if (odg.IsSuccessStatusCode)
            {
                var sodrzhina = await odg.Content.ReadAsStringAsync();               
                return xml;
            }
            else
            {
                var sodrzhina = await odg.Content.ReadAsStringAsync();
                var res = JsonConvert.DeserializeObject<ErrorModel>(sodrzhina);
                throw new Exception("Грешка");
            }
        }
        
    }
}
