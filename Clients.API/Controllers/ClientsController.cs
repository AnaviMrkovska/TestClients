using Microsoft.AspNetCore.Mvc;
using Clients.DataAccess;
using Clients.DataAccess.Repository.IRepository;
using Clients.Models;
using System.Xml;

namespace Clients.API.Controllers
{
    [ApiController]
    [Route("api/[controller]/[action]")]
    public class ClientsController : ControllerBase
    {       

        private readonly ILogger<ClientsController> _logger;
        private readonly IClientsRepository _clientsRepo;
        public ClientsController(ILogger<ClientsController> logger, IClientsRepository clientsRepo)
        {
            _logger = logger;
            _clientsRepo = clientsRepo;            
        }       

        [HttpGet]
        public async Task<IActionResult> GetAllClients()
        {
            try
            {
                IQueryable<Clients.Models.Clients> clients =  await _clientsRepo.GetAllClientsFromDatabase();               
                return Ok(clients);
            }
            catch (Exception ex)
            {
                return BadRequest(new ErrorModel { Title = "Error", ErrorMessage = ex.Message, StatusCode = 400 });
            }

        }
        [HttpPost]
        public async Task<IActionResult> InsertClientsFromXml(ClientsImport xml)
        {
            try
            {
                var result = await _clientsRepo.InsertClientsFromXml(xml);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(new ErrorModel { Title="Error",ErrorMessage= ex.Message, StatusCode=400});
            }

        }
        [HttpPost]
        public async Task<IActionResult> InsertClient(Clients.Models.Clients client)
        {
            try
            {
                var result = await _clientsRepo.InsertClient(client);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(new ErrorModel { Title = "Error", ErrorMessage = ex.Message, StatusCode = 400 });
            }

        }
    }
}
