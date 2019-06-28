#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include <algorithm>

#include <dune/common/exceptions.hh>         // We use exceptions
#include <dune/common/parallel/mpihelper.hh> // An initializer of MPI
#include <dune/common/parametertree.hh>
#include <dune/common/parametertreeparser.hh>

#include <dune/testtools/outputtree.hh>

#include <duneuro/common/matrix_utilities.hh>
#include <duneuro/eeg/eeg_analytic_solution.hh>
#include <duneuro/io/dipole_reader.hh>
#include <duneuro/io/field_vector_reader.hh>
#include <duneuro/meeg/meeg_driver_factory.hh>

#include <iostream>

// compute the 2-norm of a vector
template <class T>
T norm(const std::vector<T> &v)
{
  return std::sqrt(std::inner_product(v.begin(), v.end(), v.begin(), T(0.0)));
}

template <class T>
T absolute_error(const std::vector<T> &num, const std::vector<T> &ana)
{
  std::vector<T> diff;
  std::transform(num.begin(), num.end(), ana.begin(), std::back_inserter(diff),
                 [](const T &a, const T &b) { return a - b; });
  return norm(diff);
}

template <class T>
T relative_error(const std::vector<T> &num, const std::vector<T> &ana)
{
  std::vector<T> diff;
  std::transform(num.begin(), num.end(), ana.begin(), std::back_inserter(diff),
                 [](const T &a, const T &b) { return a - b; });
  return norm(diff) / norm(ana);
}

// compute \|num\|/\|ana\|
template <class T>
T magnitude_error(const std::vector<T> &num, const std::vector<T> &ana)
{
  return norm(num) / norm(ana);
}

// compute \| num/\|num\| - ana/\|ana\|
template <class T>
T rdm_error(const std::vector<T> &num, const std::vector<T> &ana)
{
  auto nn = norm(num);
  auto na = norm(ana);
  std::vector<T> diff;
  std::transform(num.begin(), num.end(), ana.begin(), std::back_inserter(diff),
                 [nn, na](const T &a, const T &b) { return a / nn - b / na; });
  return norm(diff);
}

// subtract the mean of each entry
template <class T>
void subtract_mean(std::vector<T> &sol)
{
  T mean = std::accumulate(sol.begin(), sol.end(), T(0.0)) / sol.size();
  for (auto &s : sol)
    s -= mean;
}

int run(const Dune::ParameterTree &config)
{
  // set up driver
  auto driver = duneuro::MEEGDriverFactory<3>::make_meeg_driver(config);
  auto electrodes = duneuro::FieldVectorReader<double, 3>::read(config.sub("electrodes"));
  driver->setElectrodes(electrodes, config.sub("electrodes"));
  driver->setSourceModel(config.sub("solution.source_model"));

  // compute transfer matrix
  auto transfer = driver->computeEEGTransferMatrix(config.sub("solution"));

  auto solution = driver->makeDomainFunction();

  // read dipoles
  auto dipoles = duneuro::DipoleReader<double, 3>::read(config.sub("dipoles"));

  // store output in an output tree
  Dune::OutputTree output(config.get<std::string>("output.filename") + "." + config.get<std::string>("output.extension"));

  std::vector<double> leadField;

  // compute lead field
  for (unsigned int i = 0; i < dipoles.size(); ++i)
  {
    auto num_transfer =
        driver->applyEEGTransfer(*transfer, dipoles[i], config.sub("solution"));

    auto prefix = std::string("dipole_") + std::to_string(i) + ".";
    leadField.push_back(num_transfer));
    output.set(prefix + "lf", leadField.back());
  }

  return 0;
}

int main(int argc, char **argv)
{
  try
  {
    // Maybe initialize MPI
    Dune::MPIHelper::instance(argc, argv);
    if (argc != 2)
    {
      std::cerr << "please provide a config file";
      return -1;
    }
    Dune::ParameterTree config;
    Dune::ParameterTreeParser::readINITree(argv[1], config);
    return run(config);
  }
  catch (Dune::Exception &e)
  {
    std::cerr << "Dune reported error: " << e << std::endl;
  }
  catch (...)
  {
    std::cerr << "Unknown exception thrown!" << std::endl;
  }
}
